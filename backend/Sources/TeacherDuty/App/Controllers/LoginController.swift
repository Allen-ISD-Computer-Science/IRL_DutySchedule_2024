// Copyright (C) 2023 Muqadam Sabir, Ryan Hallock, David Ben-Yaakov
// This program was developed using codermerlin.academy resources.
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see https://www.gnu.org/licenses/.

import Fluent
import Vapor

/* Collection of routes for the login API */
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("createuser") {req -> LoginError in
            try User.Email.validate(content: req)
            let create = try req.content.decode(User.Email.self)

            //TODO abstract this into email api
            func sendVerifyEmail(token: String?) async throws {
                let tokenURL = GlobalConfiguration.cached.vaporServerPublicURL.appendingPathComponent("verify").appendingPathComponent(token ?? "broken")
                let response = try await req.client.post(GlobalConfiguration.cached.notificationAPIURI) { req in
                    let contact = Contact(firstName: create.firstName, lastName: create.lastName, emailAddress: create.email)
                    let emailData = EmailData(contact: contact,
                                              templateExternalID: GlobalConfiguration.cached.notificationTemplateID_verifyAccount,
                                              templateParameters:
                                                "{\"firstName\": \"\(create.firstName)\", \"lastName\": \"\(create.lastName)\", \"tokenURL\": \"\(tokenURL)\"}")

                    try req.content.encode(emailData)

                    req.headers.add(name: "apiKey", value: GlobalConfiguration.cached.notificationAPIKey)
                }

                guard response.status == .ok else {
                    print(response)
                    throw Abort(.failedDependency, reason: "Email API failed to process request.")
                }
            }

            // CHECK IF A USER WITH THAT EMAIL ALREADY EXISTS
            let userExist = try await User.query(on: req.db).filter(\.$email == create.email).with(\.$authenticators).first()

            // IF A USER WITH THAT EMAIL DOESNT ALREADY EXIST CREATE NEW USER
            if let user = userExist {
                if user.hasPassword() {
                    return LoginError(error: "Account already is verfied, did you mean to reset?")
                }

                //User no longer is verfied path
                let authenticator = user.getPasswordAuthenticator()! // TODO: No banging without protection! This will fail if an account is created but not verified followed by a subsequent attempt to create the account.

                if let updateTime = authenticator.modificationTimestamp, updateTime.distance(to: Date()) > 180 {
                    authenticator.resetToken = randomString(length: 64)

                    try await sendVerifyEmail(token: authenticator.resetToken)

                    try await authenticator.update(on: req.db)

                    return LoginError(error: "Another email has been sent, click the link in your email to proceed.")
                }

                return LoginError(error: "Please wait 3 minutes before trying again.")
            }


            let user = User()
            user.firstName = create.firstName
            user.lastName = create.lastName
            user.email = create.email
//            user.$role.id = try await Role.defaultRole(on: req.db).id! // default role, querrys db too!

            let authenticator = UserAuthentication()
            authenticator.resetToken = randomString(length: 64)

            try await sendVerifyEmail(token: authenticator.resetToken)

            // Create user and authenticator
            try await user.create(on: req.db)
            try await user.$authenticators.create(authenticator, on: req.db)

            return LoginError(error: "Click the link in your email to complete account creation. If you did not recieve an email please wait 3 minutes and then try again.")
        }
        
        
        routes.post("forgot") {req -> LoginError in
            try User.Email.validate(content: req)
            let create = try req.content.decode(User.Email.self)
            
            guard let user = try await User.query(on: req.db).filter(\.$email == create.email).with(\.$authenticators).first(), user.hasPassword() else {
                return LoginError(error: "User does not exist. Check the email and try again.")
            }

            guard let authenticator = user.getPasswordAuthenticator(returnNullableToken: true) else {
                if user.authenticators.count > 1 {
                    return LoginError(error: "User does not have this login method enabled.")
                }

                return LoginError(error: "User is not active, please try registering again.")
            }

            if let updateTime = authenticator.modificationTimestamp, updateTime.distance(to: Date()) > 180 {
                authenticator.resetToken = randomString(length: 64)
                guard let resetToken = authenticator.resetToken else {
                    throw Abort(.failedDependency, reason: "Internal error, resetToken is not available.") // TODO: Examine error response 
                }

                let response = try await req.client.post(GlobalConfiguration.cached.notificationAPIURI) { req in
                    let tokenURL = GlobalConfiguration.cached.vaporServerPublicURL.appendingPathComponent("forgotpassword").appendingPathComponent(resetToken)
                    let contact = Contact(firstName: "", lastName: "", emailAddress: create.email)
                    let emailData = EmailData(contact: contact,
                                              templateExternalID: GlobalConfiguration.cached.notificationTemplateID_forgotPassword,
                                              templateParameters:
                                                "{\"firstName\": \"\(create.firstName)\", \"lastName\": \"\(create.lastName)\", \"tokenURL\": \"\(tokenURL)\"}")

                    try req.content.encode(emailData)

                    req.headers.add(name: "apiKey", value: GlobalConfiguration.cached.notificationAPIKey)
                }

                guard response.status == .ok else {
                    print(response)
                    throw Abort(.failedDependency, reason: "Email API failed to process request.")
                }

                try await authenticator.update(on: req.db)

                return LoginError(error: "Email has been sent, click the link in your email to proceed.")
            }

            return LoginError(error: "Please wait 3 minutes before trying again.")
        }

        routes.post("verify") { req -> LoginError in
            try User.Verify.validate(content: req)
            let create = try req.content.decode(User.Verify.self)

            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest, reason: "Passwords did not match")
            }

            guard let authenticator = try await UserAuthentication.query(on: req.db).filter(\.$resetToken == create.token).first() else {
                return LoginError(error: "User not found.")
            }

            guard authenticator.isPassword() else {
                return LoginError(error: "Verfication action not supported.")
            }

            guard !authenticator.isActive() else {
                return LoginError(error: "User is already verfied.")
            }

            let passwordHash = try Bcrypt.hash(create.password)

            authenticator.token = passwordHash
            authenticator.resetToken = nil
            authenticator.resetTimestamp = Date()

            try await authenticator.update(on: req.db)

            return LoginError(error: "User has been successfully created.")
        }
        
        routes.post("forgotPassword") { req -> LoginError in
            try User.Verify.validate(content: req)
            let create = try req.content.decode(User.Verify.self)

            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest, reason: "Passwords did not match")
            }

            guard let authenticator = try await UserAuthentication.query(on: req.db).filter(\.$resetToken == create.token).first() else {
                return LoginError(error: "User not found.")
            }

            guard authenticator.isActive() && authenticator.isPassword() else {
                return LoginError(error: "User requires registeration.")
            }

            let passwordHash = try Bcrypt.hash(create.password)

            authenticator.token = passwordHash
            authenticator.resetToken = nil
            authenticator.resetTimestamp = Date()

            try await authenticator.update(on: req.db)

            return LoginError(error: "User password authentication has been reset.")
        }


        // Authenticate the user and redirect to class selection page
        let sessions = routes.grouped([User.sessionAuthenticator(), User.credentialsAuthenticator(), User.guardMiddleware()])
        sessions.post("login") { req -> LoginError in
            LoginError(error: "Success")
        }
    }
    struct LoginError: Content {
        let error: String
    }
    
    struct Contact: Content {
        let firstName: String
        let lastName: String
        let emailAddress: String
    }
    
    struct EmailData: Content {
        let contact: Contact
        let templateExternalID: String
        let templateParameters: String
    }
    
    

}
