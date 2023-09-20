import Vapor
import Fluent
import FluentMySQLDriver
import Crypto


func routes(_ app: Application) throws {

    /* Function that returns the content of the `index.html` file from the Public folder */
    func serveIndex(_ req: Request, _ app: Application) -> Response {
        return req.fileio.streamFile(at: "\(app.directory.publicDirectory)/index.html")
    }

    // 1
    app.get("") {req in
        // todo: if a user, redirect to 
        req.redirect(to: "./signin")
    }
    
    app.get("signin") { req in
        req.auth.logout(User.self)
        return serveIndex(req, app)
    }
    
    app.get("signup") { req in
        return serveIndex(req, app)
    }

    app.get("verify", ":token") {req in
        //let token = req.parameters.get("token")!
        //let user = try await User.query(on: req.db).filter(\.$token == token).first()
        
        //TODO: if the user is already verified, redirect to login
        return serveIndex(req, app)
    }
    
    app.get("updateAccount", ":token") {req in
        //let token = req.parameters.get("token")!
        //let user = try await User.query(on: req.db).filter(\.$token == token).first()
        
        //TODO: if the user is already verified, redirect to login
        return serveIndex(req, app)
    }

    app.get("forgot") {req in
        return serveIndex(req, app)
    }

    /// START CORE SITE ENDPOINTS
    
   // Create protected route group which requires user auth. 
   let sessions = app.grouped([User.sessionAuthenticator(), User.customAuthenticator()])
   let protected = sessions.grouped(User.redirectMiddleware(path: "./signin"))
   let adminProtected = sessions.grouped([EnsureAdminUserMiddleware(), User.redirectMiddleware(path: "./dashboard")])
   
   adminProtected.get("adminPanel") { req in
       return serveIndex(req, app)
   }

    protected.get("dashboard") { req in
        return serveIndex(req, app)
    }
   
    protected.get("index") {req -> View in
        return try await req.view.render("index.html")
    }
    
    adminProtected.get("adminPanel", "data") { req -> [User] in
        let users = try await User.query(on: req.db).all()
        return users
    }

    adminProtected.patch("adminPanel", "updateUser", ":id") { req async throws -> User in 
        // Decode the request data.
        let patch = try req.content.decode(User.Patch.self)
        // Fetch the desired user from the database.
        guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
        throw Abort(.notFound)
    }
        // If first name was supplied, update it.
        if let firstName = patch.firstName {
            user.firstName = firstName
        }
        // If new last name was supplied, update it.
        if let lastName = patch.lastName {
            user.lastName = lastName
        }
        // If new last name was supplied, update it.
        if let email = patch.email {
            user.email = email
        }
        // Save the user and return it.
        try await user.save(on: req.db)
        return user
    }

    protected.get("userPermission") { req -> Int in
        let user = try req.auth.require(User.self)
        if user != nil {
            return user.isAdmin
        }
        return 0
    }
    
    protected.get("logout") { req -> Response in
        req.auth.logout(User.self)
        return req.redirect(to: "./login")
    }
    
    /// END CORE SITE ENDPOINTS

    try app.register(collection: LoginController())
    
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
