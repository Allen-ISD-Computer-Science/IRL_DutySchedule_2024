import Fluent
import Vapor

/* Collection of routes for the login API */
struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        routes.post("createuser") {req -> CustomError in
            try User.Email.validate(content: req)
            let create = try req.content.decode(User.Email.self)
            
            let verifyToken = randomString(length: 6)
            let user = User(
              firstName: create.firstName,
              lastName: create.lastName,
              email: create.email,
              passwordHash: "NULL",
              token: verifyToken
            )
            
            // CHECK IF A USER WITH THAT EMAIL ALREADY EXISTS
            let userExist = try await User.query(on: req.db).filter(\.$email == user.email).first()
            
            if userExist?.isActive == 1 {
                let error = CustomError(error: "Account already created and verified.")
                return error
            }
            
            
            // IF A USER WITH THAT EMAIL DOESNT ALREADY EXIST CREATE NEW USER
            if userExist != nil{
                if userExist?.isActive == 0 {
                    let curTime = Date()
                    let updatedAtTime = userExist?.updatedAt
                    if updatedAtTime!.distance(to: curTime) > Double(180) {
                        
                        let emailApi = TeacherDuty.getEnvString("EMAIL_API")
                        let response = try await req.client.post("\(emailApi)") { req in
                            let contact = Contact(firstName: create.firstName, lastName: create.lastName, emailAddress: create.email)
                            let emailData = EmailData(contact: contact,
                                                      templateName: "cmwModelSchedulerVerification",
                                                      templateParameters:
                                                        "{\"firstName\": \"\(create.firstName)\", \"lastName\": \"\(create.lastName)\", \"token\": \"\(verifyToken)\"}")
                            
                            try req.content.encode(emailData)
                            
                            req.headers.add(name: "apiKey", value: TeacherDuty.getEnvString("EMAIL_APIKEY"))
                            print("REQUEST: \n \(req)")
                        }
                        print("RESPONSE: \n \(response)")
                        
                        try await User.query(on: req.db)
                          .set(\.$token, to: verifyToken)
                          .filter(\.$email == create.email)
                          .update()
                        
                        let error = CustomError(error: "Another email has been sent, click the link in your email to proceed.")
                        return error
                    }
                    else {
                        let error = CustomError(error: "Please wait 3 minutes before trying again.")
                        return error
                    }
                }
            }
            else {
                let emailApi = TeacherDuty.getEnvString("EMAIL_API")
                let response = try await req.client.post("\(emailApi)") { req in
                    let contact = Contact(firstName: create.firstName, lastName: create.lastName, emailAddress: create.email)
                    let emailData = EmailData(contact: contact,
                                              templateName: "cmwModelSchedulerVerification",
                                              templateParameters:
                                                "{\"firstName\": \"\(create.firstName)\", \"lastName\": \"\(create.lastName)\", \"token\": \"\(verifyToken)\"}")
                    
                    try req.content.encode(emailData)
                    
                    req.headers.add(name: "apiKey", value: TeacherDuty.getEnvString("EMAIL_APIKEY"))
                    print("REQUEST: \n \(req)")
                }
                print("RESPONSE: \n \(response)")
                
                try await user.save(on: req.db)
                let error = CustomError(error: "Click the link in your email to complete account creation. If you did not recieve an email please wait 3 minutes and then try again.")
                return error
                
            }
            
            
            let error = CustomError(error: "Fatal Error, please try again later.")
            return error
        }
        
        routes.post("verify") { req -> CustomError in
            try User.Verify.validate(content: req)
            let create = try req.content.decode(User.Verify.self)
            let token = create.token
            guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
            let passwordHash = try Bcrypt.hash(create.password)
            let user = try await User.query(on: req.db).filter(\.$token == token).first()
            if user?.isActive == 0 {
                try await User.query(on: req.db)
                  .set(\.$passwordHash, to: passwordHash)
                  .set(\.$isActive, to: 1)
                  .filter(\.$token == token)
                  .update()
                
                let error = CustomError(error: "Account successfully created.")
                return error
            }
            else if user?.isActive == 1 {
                let error = CustomError(error: "Account already verified.")
                return error
            }
            
            let error = CustomError(error: "Fatal Error, please try again later.")
            return error
        }
        
        routes.post("forgot") {req -> CustomError in
            try User.Email.validate(content: req)
            let create = try req.content.decode(User.Email.self)
            
            let verifyToken = randomString(length: 6)
            let user = User(
              firstName: create.firstName,
              lastName: create.lastName,
              email: create.email,
              passwordHash: "NULL",
              token: verifyToken
            )
            
            let userExist = try await User.query(on: req.db).filter(\.$email == user.email).first()
            
            if userExist != nil{
                if userExist?.isActive == 1 {
                    let curTime = Date()
                    let updatedAtTime = userExist?.updatedAt
                    if updatedAtTime!.distance(to: curTime) > Double(180) {
                        
                        let emailApi = TeacherDuty.getEnvString("EMAIL_API")
                        let response = try await req.client.post("\(emailApi)") { req in
                            let contact = Contact(firstName: "", lastName: "", emailAddress: create.email)
                            let emailData = EmailData(contact: contact,
                                                      templateName: "cmwModelSchedulerForgotPassword",
                                                      templateParameters:
                                                        "{\"firstName\": \"\(create.firstName)\", \"lastName\": \"\(create.lastName)\", \"token\": \"\(verifyToken)\"}")
                            
                            try req.content.encode(emailData)
                            
                            req.headers.add(name: "apiKey", value: TeacherDuty.getEnvString("EMAIL_APIKEY"))
                        }
                        
                        try await User.query(on: req.db)
                          .set(\.$token, to: verifyToken)
                          .filter(\.$email == create.email)
                          .update()
                        
                        let error = CustomError(error: "Email has been sent, click the link in your email to proceed.")
                        return error
                    }
                    else {
                        let error = CustomError(error: "Please wait 3 minutes before trying again.")
                        return error
                    }
                }
            }
            else {
                
                let error = CustomError(error: "User does not exist. Check the email and try again.")
                return error
                
            }
            
            
            let error = CustomError(error: "Fatal Error, please try again later.")
            return error
            
        }
        
        routes.post("forgotpassword") { req -> CustomError in
            try User.Verify.validate(content: req)
            let create = try req.content.decode(User.Verify.self)
            let token = create.token
            guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
            let passwordHash = try Bcrypt.hash(create.password)
            let user = try await User.query(on: req.db).filter(\.$token == token).first()
            if user?.isActive == 1 {
                try await User.query(on: req.db)
                  .set(\.$passwordHash, to: passwordHash)
                  .filter(\.$token == token)
                  .update()
                
                let error = CustomError(error: "Password successfully updated.")
                return error
            }
            else if user?.isActive == 0 {
                let error = CustomError(error: "Account is not active.")
                return error
            }
            
            let error = CustomError(error: "Fatal Error, please try again later.")
            return error
        }
        
        
        // Authenticate the user and redirect to class selection page
        let sessions = routes.grouped([User.sessionAuthenticator(), User.customAuthenticator()])
        sessions.post("login") { req -> CustomError in
            try req.auth.require(User.self)
            let error = CustomError(error:"Success")
            return error
        }
        
    }

    
    struct CustomError: Content {
        let error: String
    }
    
    struct Contact: Content {
        let firstName: String
        let lastName: String
        let emailAddress: String
    }
    
    struct EmailData: Content {
        let contact: Contact
        let templateName: String
        let templateParameters: String
    }
    
    
    
}
