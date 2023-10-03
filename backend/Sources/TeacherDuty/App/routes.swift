import Vapor
import Fluent
import FluentMySQLDriver
import Crypto


func routes(_ app: Application) throws {

    func renderIndex(_ request: Request) async throws ->  View {
        return try await request.view.render("index.html")
    }

    app.get("") {req in
        req.redirect(to: "./signin")
    }

    app.get("signin") { req in
         return try await renderIndex(req)
    }

    app.get("signup") { req in
        return try await renderIndex(req)
    }

    app.get("forgot") { req in
        return try await renderIndex(req)
    }

    app.get("verify", "*") { req in
         return try await renderIndex(req)
    }

    app.get("forgotPassword", "*") { req in
        return try await renderIndex(req)
    }

    /// START CORE SITE ENDPOINTS
    
    // Create protected route group which requires user auth.
    let sessions = app.grouped([User.sessionAuthenticator(), User.credentialsAuthenticator()])
    let protected = sessions.grouped(User.redirectMiddleware(path: "./signin"))

    protected.get("index") { req in
        return try await renderIndex(req)
    }

    protected.get("dashboard") { req in
        return try await renderIndex(req)
    }

    protected.get("calendar") { req in
        return try await renderIndex(req)
    }

    struct CalendarDataRes : Content {
        var day : Date
        var dayOfWeek: Int?
        var supplementaryJSON : OptionalSupplementaryJSON
    }

    struct CalendarDataReq : Content {
        var from: Date
        var through: Date
    }
    
    protected.post("calendar", "data") { req async throws -> [CalendarDataRes] in
        let user = try req.auth.require(User.self)
        let calendarDataReq = try req.content.decode(CalendarDataReq.self)

        let days = try await Day.query(on: req.db)
          .filter(\.$day >= calendarDataReq.from)
          .filter(\.$day <= calendarDataReq.through)
          .field(\.$day)
          .field(\.$dayOfWeek)
          .field(\.$supplementaryJSON)
          .all()
          .map { day in
              CalendarDataRes.init(day: day.day, dayOfWeek: day.dayOfWeek!, supplementaryJSON: day.supplementaryJSON)
          }

        return days
    }
   
    protected.get("userPermission") { req -> Int in
        let user = try req.auth.require(User.self)

        if user.$role.value == nil {
            try await user.$role.load(on: req.db)
        }

        let adminRole = try await Role.adminRole(on: req.db)

        guard user.role == adminRole else {
            return 0
        }

        return 1
    }
    
    protected.get("logout") { req in
        req.auth.logout(User.self)
        return req.redirect(to: "./signin")
    }


    let adminProtected = protected.grouped(EnsureAdminUserMiddleware())

    adminProtected.get("adminPanel") { req in
        return try await renderIndex(req)
    }

    adminProtected.get("adminPanel", "upload") { req in
       return try await renderIndex(req)
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
