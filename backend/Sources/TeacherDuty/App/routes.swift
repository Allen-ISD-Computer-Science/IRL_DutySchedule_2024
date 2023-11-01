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

    struct DutiesDataRes : Content {
        var startTime : String
        var endTime : String
        var day : Date
        var dayOfWeek : Int?
        var dayType : OptionalSupplementaryJSON
        var dutyName : String
        var dutyDescription : String
        var locationName : String
        var locationDescription : String
    }

    struct DutiesDataReq : Content {
        var from: Date
        var through: Date
    }
    
    protected.post("duties", "user", "date") {req async throws -> [DutiesDataRes] in
        let user = try req.auth.require(User.self)
        let dutiesDataReq = try req.content.decode(DutiesDataReq.self)
        var dutiesDataRes = [DutiesDataRes]()
        
        guard let userId = user.id else {
            app.logger.warning("User `\(user.email)` does not have id field.")
            throw Abort(.unauthorized, reason: "User `\(user.email)` does not have id field")
        }
        
        let userShifts = try await UserShifts.query(on: req.db)
          .join(User.self, on: \UserShifts.$user.$id == \User.$id)
          .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
          .filter(User.self, \.$id == userId)
          .all()
        //TODO: Use the role to find the users context
        /*      
                let userRole = try await UserRoles.query(on: req.db)
                .join(User.self, on: \UserRoles.$user.$id == \User.$id)
                .join(Role.self, on: \UserRoles.$role.$id == \Role.$id)
                .filter(User.self, \.$id == userId)
                .first()

                let role = try userRole!.joined(Role.self)
         */        
        
        for userShift in userShifts {
            let shift = try userShift.joined(Shift.self)

            guard let shiftId = shift.id else {
                app.logger.warning("Shift does not have id field.")
                throw Abort(.unauthorized, reason: "Shift does not have id field")
            }

            //TODO: filter all of these joins by context
            let shiftDayPos = try await Shift.query(on: req.db)
              .join(Day.self, on: \Shift.$day.$id == \Day.$id)
              .join(Position.self, on: \Shift.$position.$id == \Position.$id)
              .filter(Day.self, \.$day >= dutiesDataReq.from)
              .filter(Day.self, \.$day <= dutiesDataReq.through)
              .filter(Shift.self, \.$id == shiftId)
              .first()

            if shiftDayPos != nil {
                let shiftDutyLoc = try await Position.query(on: req.db)
                  .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
                  .join(Location.self, on: \Position.$location.$id == \Location.$id)
                  .filter(Position.self, \.$id == shiftDayPos!.$position.id)
                  .first()
                
                let position = try shiftDayPos!.joined(Position.self)
                let dayModel = try shiftDayPos!.joined(Day.self)
                let location = try shiftDutyLoc!.joined(Location.self)
                let duty = try shiftDutyLoc!.joined(Duty.self)
                
                let startTime = shift.start
                let endTime = shift.end
                let day = dayModel.day
                let dayOfWeek = dayModel.dayOfWeek
                let dayType = dayModel.supplementaryJSON
                let dutyName = duty.name
                let dutyDescription = duty.description
                let locationName = location.name
                let locationDescription = location.description
                
                let dutiesData = DutiesDataRes.init(
                  startTime: startTime,
                  endTime: endTime,
                  day: day,
                  dayOfWeek: dayOfWeek,
                  dayType: dayType,
                  dutyName: dutyName,
                  dutyDescription: dutyDescription,
                  locationName: locationName,
                  locationDescription: locationDescription
                )
                
                dutiesDataRes.append(dutiesData)
            }
        }
        print("Duties Date Count: \(dutiesDataRes.count)")
        return dutiesDataRes
    }

    
    struct DutiesCountDataReq : Content {
        var from : Date // Date from which you want to start seeking UserShifts
        var count : Int // Amount of UserShifts you want to be returned after the from date
    }

    protected.post("duties", "user", "count") {req async throws -> [DutiesDataRes] in
        let user = try req.auth.require(User.self)
        let dutiesDataReq = try req.content.decode(DutiesCountDataReq.self)
        var dutiesDataRes = [DutiesDataRes]()
        
        guard let userId = user.id else {
            app.logger.warning("User `\(user.email)` does not have id field.")
            throw Abort(.unauthorized, reason: "User `\(user.email)` does not have id field")
        }
        
        let userShifts = try await UserShifts.query(on: req.db)
          .join(User.self, on: \UserShifts.$user.$id == \User.$id)
          .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
          .filter(User.self, \.$id == userId)
          .limit(dutiesDataReq.count)
          .all()

        //TODO: Use the role to find the users context
        /*      
                let userRole = try await UserRoles.query(on: req.db)
                .join(User.self, on: \UserRoles.$user.$id == \User.$id)
                .join(Role.self, on: \UserRoles.$role.$id == \Role.$id)
                .filter(User.self, \.$id == userId)
                .first()
                
                let role = try userRole!.joined(Role.self)
         */        
        
        for userShift in userShifts {
            let shift = try userShift.joined(Shift.self)

            guard let shiftId = shift.id else {
            app.logger.warning("Shift does not have id field.")
            throw Abort(.unauthorized, reason: "Shift does not have id field")
        }

            //TODO: filter all of these joins by context
            let shiftDayPos = try await Shift.query(on: req.db)
              .join(Day.self, on: \Shift.$day.$id == \Day.$id)
              .join(Position.self, on: \Shift.$position.$id == \Position.$id)
              .filter(Day.self, \.$day >= dutiesDataReq.from)
              .filter(Shift.self, \.$id == shiftId)
              .first()

            if shiftDayPos != nil {
                
                let shiftDutyLoc = try await Position.query(on: req.db)
                  .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
                  .join(Location.self, on: \Position.$location.$id == \Location.$id)
                  .filter(Position.self, \.$id == shiftDayPos!.$position.id)
                  .first()
                
                let position = try shiftDayPos!.joined(Position.self)
                let dayModel = try shiftDayPos!.joined(Day.self)
                let location = try shiftDutyLoc!.joined(Location.self)
                let duty = try shiftDutyLoc!.joined(Duty.self)
            
                let startTime = shift.start
                let endTime = shift.end
                let day = dayModel.day
                let dayOfWeek = dayModel.dayOfWeek
                let dayType = dayModel.supplementaryJSON
                let dutyName = duty.name
                let dutyDescription = duty.description
                let locationName = location.name
                let locationDescription = location.description
                
                let dutiesData = DutiesDataRes.init(
                  startTime: startTime,
                  endTime: endTime,
                  day: day,
                  dayOfWeek: dayOfWeek,
                  dayType: dayType,
                  dutyName: dutyName,
                  dutyDescription: dutyDescription,
                  locationName: locationName,
                  locationDescription: locationDescription
                )
                
                dutiesDataRes.append(dutiesData)
            }
        }
        
        return dutiesDataRes
    }
   
    
    protected.get("userPermission") { req -> Int in
        let user = try req.auth.require(User.self)

        guard let userId = user.id else {
            app.logger.warning("User `\(user.email)` does not have id field.")
            return 0 // How?
        }

        guard let adminRoleId = try await Role.adminRole(on: req.db).id else {
            app.logger.critical("Admin role not located.")
            return 0
        }

        guard try await UserRoles.query(on: req.db)
                .filter(\.$user.$id == userId)
                .filter(\.$role.$id == adminRoleId)
                .count() == 1 else {
            // User does not have the admin role.
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
