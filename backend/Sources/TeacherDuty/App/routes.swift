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
    let protected = sessions.grouped(User.redirectMiddleware(path: GlobalConfiguration.cached.vaporServerPublicURL.absoluteString + "/signin"))

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

        guard let userId = user.id else {
            throw Abort(.unauthorized, reason: "User `\(user.email)` does not have id field")
        }

        let userShifts = try await UserShifts.query(on: req.db)
          .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
          .join(Day.self, on: \Shift.$day.$id == \Day.$id)
          .join(Position.self, on: \Shift.$position.$id == \Position.$id)
          .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
          .join(Location.self, on: \Position.$location.$id == \Location.$id)
          .filter(UserShifts.self, \UserShifts.$user.$id == userId)
          .filter(Day.self, \.$day >= dutiesDataReq.from)
          .filter(Day.self, \.$day <= dutiesDataReq.through)
        //.context(Duty.self, Day.self).context(Duty.self, Location.self) Already checked by SQL database on insertion
          .all()

        let dutiesDataRes = try userShifts.map { userShift in
            let shift = try userShift.joined(Shift.self)
            let dayModel = try userShift.joined(Day.self)
            let location = try userShift.joined(Location.self)
            let duty = try userShift.joined(Duty.self)

            let startTime = shift.start
            let endTime = shift.end
            let day = dayModel.day
            let dayOfWeek = dayModel.dayOfWeek
            let dayType = dayModel.supplementaryJSON
            let dutyName = duty.name
            let dutyDescription = duty.description
            let locationName = location.name
            let locationDescription = location.description

            let dutieData = DutiesDataRes.init(
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

            return dutieData
        }

        return dutiesDataRes
    }

    
    struct DutiesCountDataReq : Content {
        var from : Date // Date from which you want to start seeking UserShifts
        var count : Int // Amount of UserShifts you want to be returned after the from date
    }

    //TODO rename route to limit
    protected.post("duties", "user", "count") {req async throws -> [DutiesDataRes] in
        let user = try req.auth.require(User.self)
        let dutiesDataReq = try req.content.decode(DutiesCountDataReq.self)

        guard let userId = user.id else {
            throw Abort(.unauthorized, reason: "User `\(user.email)` does not have id field")
        }

        let userShifts = try await UserShifts.query(on: req.db)
          .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
          .join(Day.self, on: \Shift.$day.$id == \Day.$id)
          .join(Position.self, on: \Shift.$position.$id == \Position.$id)
          .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
          .join(Location.self, on: \Position.$location.$id == \Location.$id)
          .filter(UserShifts.self, \UserShifts.$user.$id == userId)
          .filter(Day.self, \Day.$day >= dutiesDataReq.from)
        //.context(Duty.self, Day.self).context(Duty.self, Location.self) Already checked by SQL database on insertion
          .limit(dutiesDataReq.count)
          .all()

        let dutiesDataRes = try userShifts.map { userShift in
            let shift = try userShift.joined(Shift.self)
            let dayModel = try userShift.joined(Day.self)
            let location = try userShift.joined(Location.self)
            let duty = try userShift.joined(Duty.self)

            let startTime = shift.start
            let endTime = shift.end
            let day = dayModel.day
            let dayOfWeek = dayModel.dayOfWeek
            let dayType = dayModel.supplementaryJSON
            let dutyName = duty.name
            let dutyDescription = duty.description
            let locationName = location.name
            let locationDescription = location.description

            let dutieData = DutiesDataRes.init(
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

            return dutieData
        }

        return dutiesDataRes
    }


    /// Endpoint that returns the availability of a user
    struct UserAvailabilityDataRes : Content {
        var startTime : String
        var endTime : String
        var day : Date
        var dayOfWeek : Int?
        var dayType : OptionalSupplementaryJSON
    }
    
    protected.get("user", "availability", ":id") {req async throws -> [UserAvailabilityDataRes] in
        var userAvailabilityDataRes = [UserAvailabilityDataRes]()

        guard let userID = req.parameters.get("id", as: Int.self) else {
            app.logger.warning("userID does not have a field.")
            throw Abort(.unauthorized, reason: "userID does not have a field")
        }
        guard let user = try await User.query(on: req.db).filter(\.$id == userID).first() else {
            app.logger.warning("User does not exist")
            throw Abort(.unauthorized, reason: "User does not exist")
        }

        let usersAvailability = try await UserAvailability.query(on: req.db)
          .join(User.self, on: \UserAvailability.$user.$id == \User.$id)
          .filter(User.self, \.$id == userID)
          .join(Availability.self, on: \UserAvailability.$availability.$id == \Availability.$id)
          .all()

        for userAvailability in usersAvailability {
            let availability = try userAvailability.joined(Availability.self)
            
            guard let availabilityID = availability.id else {
                app.logger.warning("Availability does not have id field.")
                throw Abort(.unauthorized, reason: "Availability does not have id field")
            }

            let availabilityDay = try await Availability.query(on: req.db)
              .join(Day.self, on: \Availability.$day.$id == \Day.$id)
              .filter(Availability.self, \.$id == availabilityID)
              .first()

            if availabilityDay != nil {
                let dayModel = try availabilityDay!.joined(Day.self)

                let startTime = availability.start
                let endTime = availability.end
                let day = dayModel.day
                let dayOfWeek = dayModel.dayOfWeek
                let dayType = dayModel.supplementaryJSON

                let userAvailabilityData = UserAvailabilityDataRes.init(
                  startTime: startTime,
                  endTime: endTime,
                  day: day,
                  dayOfWeek: dayOfWeek,
                  dayType: dayType)

                userAvailabilityDataRes.append(userAvailabilityData)
            }
        }
        return userAvailabilityDataRes
    }

    /// Endpoint that returns the availability of a user
    struct UserAvailabilitySetReq : Content {
        var startTime : String
        var endTime : String
        var day : Date
        var dayOfWeek : Int?
        var dayType : OptionalSupplementaryJSON
    }
    
    protected.post("user", "availability") {req async throws -> Bool in
        let user = try req.auth.require(User.self)
        let userAvailabilityReq = try req.content.decode(UserAvailabilitySetReq.self)

        throw Abort(.imATeapot, reason: "I am not implemented.")
        //return true
    }
    
    protected.get("userPermission") { req -> Int in
        let user = try req.auth.require(User.self)

        guard let userId = user.id else {
            app.logger.warning("User `\(user.email)` does not have id field.")
            return 0// How?
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
    
    adminProtected.get("adminPanel", "calendar") { req in
        return try await renderIndex(req)
    }
    
    /// END CORE SITE ENDPOINTS

    try app.register(collection: LoginController())

    try app.register(collection: AdminController())
    
    
}

struct CustomError: Content {
    let error: String
}
