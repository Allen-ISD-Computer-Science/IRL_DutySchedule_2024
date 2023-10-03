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
    let sessions = app.grouped([User.sessionAuthenticator(), User.credentialsAuthenticator()])
    let protected = sessions.grouped(User.redirectMiddleware(path: "./signin"))
    let adminProtected = sessions.grouped([EnsureAdminUserMiddleware(), User.redirectMiddleware(path: "./dashboard")])

    protected.get("dashboard") { req in
        return serveIndex(req, app)
    }

    protected.get("calendar") { req in
        return serveIndex(req, app)
    }

    struct CalendarDataRes : Content {
        var day : Date
        var dayOfWeek: Int?
        var supplementaryJSON : Day.DayType
    }

    struct CalendarDataReq : Content {
        var from: Date
        var through: Date
    }
    
    protected.post("calendar", "data") { req async throws -> [CalendarDataRes] in
        let user = try req.auth.require(User.self)
        let calendarDataReq = try req.content.decode(CalendarDataReq.self)
        if user != nil {
            let days = try await Day.query(on: req.db)
              .filter(\.$day >= calendarDataReq.from)
              .filter(\.$day <= calendarDataReq.through)
              .field(\.$day)
              .field(\.$dayOfWeek)
              .field(\.$supplementaryJSON)
              .all()
              .map { day in
                  CalendarDataRes.init(day: day.day, dayOfWeek: day.dayOfWeek!, supplementaryJSON: day.supplementaryJSON!)
              }
            
            return days
        }
        throw Abort(.notFound)
    }
    
    protected.get("index") {req -> View in
        return try await req.view.render("index.html")
    }
    
    adminProtected.get("adminPanel") { req in
        return serveIndex(req, app)
    }

    adminProtected.get("adminPanel", "upload") { req in
       return serveIndex(req, app)
    }
   
    protected.get("userPermission") { req -> Int in
        let user = try req.auth.require(User.self)
        if user != nil { //TODO FIX!
            return 1
        }
        return 0
    }
    
    protected.get("logout") { req -> Response in
        req.auth.logout(User.self)
        return req.redirect(to: "./login")
    }
    
    /// END CORE SITE ENDPOINTS

    try app.register(collection: LoginController())

    try app.register(collection: AdminController())
    
    
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
