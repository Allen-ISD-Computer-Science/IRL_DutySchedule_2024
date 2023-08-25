import Vapor
import Fluent
import FluentMySQLDriver
import Crypto


func routes(_ app: Application) throws {
    
    app.get("") {req in
        req.redirect(to: "./login")
    }

    app.get("login") {req -> View in
        req.auth.logout(User.self)
        return try await req.view.render("login.html")
    }

    app.get("createuser.html") {req in
        req.redirect(to: "./createuser")
    }
    
    app.get("createuser") {req in
        req.view.render("createuser.html")
    }

        //todo: return an error string
    app.post("createuser") {req -> CustomError in
        try User.Email.validate(content: req)
        let create = try req.content.decode(User.Email.self)
        
        let emailData = Data(create.email.utf8)
        let hashedEmail = SHA256.hash(data: emailData)
        //print("SAVING: \(hashedEmail.hex)")
        let verifyToken = randomString(length: 6)
        let user = User(
          email: hashedEmail.hex,
          passwordHash: "NULL",
          token: verifyToken
        )

        let userExist = try await User.query(on: req.db).filter(\.$email == user.email).first()

        if userExist?.isActive == 1 {
            let error = CustomError(error: "Account already created and verified.")
            return error
        }
        
               
        if userExist != nil{
            if userExist?.isActive == 0 {
                let curTime = Date()
                let updatedAtTime = userExist?.updatedAt
                if updatedAtTime!.distance(to: curTime) > Double(180) {

                    let emailApi = TeacherDuty.getEnvString("EMAIL_API")
                    let response = try await req.client.post("\(emailApi)") { req in
                        let contact = Contact(firstName: "", lastName: "", emailAddress: create.email)
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
                      .filter(\.$email == hashedEmail.hex)
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
                let contact = Contact(firstName: "", lastName: "", emailAddress: create.email)
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

    app.get("verify", ":token") {req in
        //let token = req.parameters.get("token")!
        //let user = try await User.query(on: req.db).filter(\.$token == token).first()
        
        //TODO: if the user is already verified, redirect to login
        return try await req.view.render("verify.html")
    }

    app.post("verify") { req -> CustomError in
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

    app.get("forgot") {req in
        return try await req.view.render("forgot.html")
    }
    

   app.get("forgotpassword", ":token") {req in
        //let token = req.parameters.get("token")!
        //let user = try await User.query(on: req.db).filter(\.$token == token).first()
        
        //TODO: if the user is already verified, redirect to login
        return try await req.view.render("forgotpassword.html")
    }

   app.post("forgot") {req -> CustomError in
       try User.Email.validate(content: req)
       let create = try req.content.decode(User.Email.self)
       
       let emailData = Data(create.email.utf8)
       let hashedEmail = SHA256.hash(data: emailData)
       //print("SAVING: \(hashedEmail.hex)")
       let verifyToken = randomString(length: 6)
       let user = User(
         email: hashedEmail.hex,
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
                     .filter(\.$email == hashedEmail.hex)
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
   
   app.post("forgotpassword") { req -> CustomError in
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
    let sessions = app.grouped([User.sessionAuthenticator(), User.customAuthenticator()])
    sessions.post("login") { req -> CustomError in
        try req.auth.require(User.self)
        let error = CustomError(error:"Success")
        return error
    }
    
    /// END LOGIN AND ACCOUNT CREATION ENDPOINTS
    
    
    /// START CORE SITE ENDPOINTS
    
    // Create protected route group which requires user auth. 
    let protected = sessions.grouped(User.redirectMiddleware(path: "./login"))
    let adminProtected = sessions.grouped([EnsureAdminUserMiddleware(), User.redirectMiddleware(path: "./index")])

    protected.get("index") {req -> View in
        return try await req.view.render("index.html")
    }
    
    adminProtected.get("adminPanel") { req -> View in
        return try await req.view.render("adminPanel.html")
    }

    adminProtected.get("adminPanel", "data") { req -> [User] in
        let users = try await User.query(on: req.db).all()
        return users
    }

    adminProtected.post("adminPanel", "createUser") { req -> CustomError in
        //TODO - Fix this endpoint to conform to new database structure
        /*
        let userCreate = try req.content.decode(User.Create.self)
        
        let user = User(
          name: userCreate.name,
          userID: userCreate.userID,
          canView: userCreate.canView,
          canEdit: userCreate.canEdit,
          isAdmin: userCreate.isAdmin
        )

        let userExist = try await User.query(on: req.db).filter(\.$userID == user.userID).first()

        if userExist == nil{
            try await user.save(on: req.db)
            let error = CustomError(error: "User Created.")
            return error
        }
        else {
            let error = CustomError(error: "User Already Exists.")
            return error
            
        }
    
         */
        let error = CustomError(error: "Fatal Error, please try again later.")
        return error
                
    }

    adminProtected.post("adminPanel", "removeUser") { req -> CustomError in
        /*
        let userRemove = try req.content.decode(User.Remove.self)
        let userExist = try await User.query(on: req.db).filter(\.$userID == userRemove.userID).first()
        
        if userExist == nil{
            let error = CustomError(error: "User Does Not Exist.")
            return error
        }
        else {
            try await userExist!.delete(force: true, on: req.db)
            
            let error = CustomError(error: "User Removed.")
            return error
            
        }
    
         */
        let error = CustomError(error: "Fatal Error, please try again later.")
        return error
    }

    protected.get("logout") { req -> Response in
        req.auth.logout(User.self)
        return req.redirect(to: "./login")
    }
    
    /// END CORE SITE ENDPOINTS
    
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
