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

            // CHECK IF A USER WITH THAT EMAIL ALREADY EXISTS
            let userExist = try await User.query(on: req.db).filter(\.$email == create.email).with(\.$authenticators).first()

            // IF A USER WITH THAT EMAIL DOESNT ALREADY EXIST CREATE NEW USER
            if let user = userExist {
                if user.hasPassword() {
                    return LoginError(error: "Account already is verfied, did you mean to reset?")
                }

                //User no longer is verfied path
                let authenticator = user.getPasswordAuthenticator()!

                if let resetTimestamp = authenticator.resetTimestamp, resetTimestamp.distance(to: Date()) < 180 {
                    return LoginError(error: "Please wait 3 minutes before trying again.")
                }

                authenticator.resetToken = randomString(length: 64)
                authenticator.resetTimestamp = Date()

                guard let verifyToken = authenticator.resetToken else {
                    throw Abort(.failedDependency, reason: "Internal error, verifyToken is not available.") // TODO: Examine error response
                }

                let contact = EmailContact(firstName: user.firstName, lastName: user.lastName, emailAddress: user.email)
                let verifyEmail = TokenURLEmail(pathComponet: "verify", token: verifyToken).createContent(with: contact)
                let emailData = EmailData(contact: contact,
                                          templateExternalID: GlobalConfiguration.cached.notificationTemplateID_verifyAccount,
                                          templateParameters: verifyEmail)

                try await GlobalEmailAPI.sendEmail(from: req, with: emailData)

                try await authenticator.update(on: req.db)

                return LoginError(error: "Another email has been sent, click the link in your email to proceed.")
            }


            let user = User()
            user.firstName = create.firstName
            user.lastName = create.lastName
            user.email = create.email
            //            user.$role.id = try await Role.defaultRole(on: req.db).id! // default role, querrys db too!

            let authenticator = UserAuthentication()
            authenticator.resetToken = randomString(length: 64)
            authenticator.resetTimestamp = Date()

            guard let verifyToken = authenticator.resetToken else {
                throw Abort(.failedDependency, reason: "Internal error, verifyToken is not available.") // TODO: Examine error response
            }

            let contact = EmailContact(firstName: user.firstName, lastName: user.lastName, emailAddress: user.email)
            let verifyEmail = TokenURLEmail(pathComponet: "verify", token: verifyToken).createContent(with: contact)
            let emailData = EmailData(contact: contact,
                                      templateExternalID: GlobalConfiguration.cached.notificationTemplateID_verifyAccount,
                                      templateParameters: verifyEmail)

            try await GlobalEmailAPI.sendEmail(from: req, with: emailData)

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

            if let resetTimestamp = authenticator.resetTimestamp, resetTimestamp.distance(to: Date()) < 180 {
                return LoginError(error: "Please wait 3 minutes before trying again.")
            }

            authenticator.resetToken = randomString(length: 64)
            authenticator.resetTimestamp = Date()

            guard let resetToken = authenticator.resetToken else {
                throw Abort(.failedDependency, reason: "Internal error, resetToken is not available.") // TODO: Examine error response
            }

            let contact = EmailContact(firstName: create.firstName, lastName: create.lastName, emailAddress: create.email)
            let forgotEmail = TokenURLEmail(pathComponet: "forgotPassword", token: resetToken).createContent(with: contact)
            let emailData = EmailData(contact: contact,
                                      templateExternalID: GlobalConfiguration.cached.notificationTemplateID_forgotPassword,
                                      templateParameters: forgotEmail)

            try await GlobalEmailAPI.sendEmail(from: req, with: emailData)


            try await authenticator.update(on: req.db)

            return LoginError(error: "Email has been sent, click the link in your email to proceed.")
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


    struct TokenURLEmail: EmailContactConsumer {
        private struct TokenURLEmailWrapper: Encodable {
            let firstName: String?
            let lastName: String?
            let tokenURL: URL
        }

        let tokenURL: URL

        init(pathComponet: String, token: String) {
            self.tokenURL = GlobalConfiguration.cached.vaporServerPublicURL
              .appendingPathComponent(pathComponet)
              .appendingPathComponent(token)
        }

        func createContent(with contact: EmailContact) -> Encodable {
            return TokenURLEmailWrapper(firstName: contact.firstName,
                                        lastName: contact.lastName,
                                        tokenURL: self.tokenURL
            )
        }
    }
}
