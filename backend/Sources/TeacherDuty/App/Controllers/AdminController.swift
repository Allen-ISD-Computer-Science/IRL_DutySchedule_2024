import Fluent
import Vapor
import MultipartKit

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sessions = app.grouped([User.sessionAuthenticator(), User.credentialsAuthenticator()])
        let adminProtected = sessions.grouped([EnsureAdminUserMiddleware(), User.redirectMiddleware(path: "./dashboard")])
        

        struct CSVObject: Decodable {
            let file: Data
        }
        
        adminProtected.post("adminPanel", "upload") { req -> EventLoopFuture<String> in
            let multipart = try req.content.decode(CSVObject.self)
            let csvData = multipart.file

            if let csvString = String(data: csvData, encoding: .utf8) {
                print("CSV Data:\n\(csvString)")
                return req.eventLoop.future("CSV file found, printed in vapor console")
            }
            
            
            throw Abort(.badRequest, reason: "CSV file not found in request")
        }

        struct AdminData : Content {
            var id : Int?
            var firstName : String
            var lastName : String
            var email : String
            var supplementaryJSON : User.Availability?
        }
        adminProtected.get("adminPanel", "data") { req -> [AdminData] in
            let users = try await User.query(on: req.db)
              .field(\.$id)
              .field(\.$firstName)
              .field(\.$lastName)
              .field(\.$email)
              .field(\.$supplementaryJSON)
              .all()
              .map { user in
                  AdminData.init(id: user.id!, firstName: user.firstName, lastName: user.lastName, email: user.email, supplementaryJSON: user.supplementaryJSON)
              }
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

        struct AdminDutiesDataRes : Content {
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
        
        struct AdminDutiesDataReq : Content {
            var from : Date // Date from which you want to start seeking UserShifts
            var count : Int // Amount of UserShifts you want to be returned after the from date
        }

        
        adminProtected.post("adminPanel", "duties", ":userID") { req async throws -> [AdminDutiesDataRes] in
            let dutiesDataReq = try req.content.decode(AdminDutiesDataReq.self)
            var dutiesDataRes = [AdminDutiesDataRes]()
            
            guard let userID = req.parameters.get("userID", as: Int.self) else {
                app.logger.warning("userID does not have a field.")
                throw Abort(.unauthorized, reason: "userID does not have a field")
            }
            guard let user = try await User.query(on: req.db).filter(\.$id == userID).first() else {
                app.logger.warning("User does not exist")
                throw Abort(.unauthorized, reason: "User does not exist")
            }
            

            let userShifts = try await UserShifts.query(on: req.db)
              .join(User.self, on: \UserShifts.$user.$id == \User.$id)
              .filter(User.self, \.$id == userID)
              .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
              .limit(dutiesDataReq.count)
              .all()
            
            for userShift in userShifts {
                let shift = try userShift.joined(Shift.self)

                guard let shiftId = shift.id else {
                    app.logger.warning("Shift does not have id field.")
                    throw Abort(.unauthorized, reason: "Shift does not have id field")
                }

                let shiftDayPos = try await Shift.query(on: req.db)
                  .join(Day.self, on: \Shift.$day.$id == \Day.$id)
                  .join(Position.self, on: \Shift.$position.$id == \Position.$id)
                  .filter(Day.self, \.$day >= dutiesDataReq.from)
                  .filter(Shift.self, \.$id == shiftId)
                  .first()


                if shiftDayPos != nil {
                    
                    guard let shiftDutyLoc = try await Position.query(on: req.db)
                            .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
                            .join(Location.self, on: \Position.$location.$id == \Location.$id)
                            .filter(Position.self, \.$id == shiftDayPos!.$position.id)
                            .first() else {
                        app.logger.warning("ShiftDutyLoc error.")
                        throw Abort(.unauthorized, reason: "ShiftDutyLoc error")
                        
                    }
                    
                    let position = try shiftDayPos!.joined(Position.self)
                    let dayModel = try shiftDayPos!.joined(Day.self)
                    let location = try shiftDutyLoc.joined(Location.self)
                    let duty = try shiftDutyLoc.joined(Duty.self)
                    
                    let startTime = shift.start
                    let endTime = shift.end
                    let day = dayModel.day
                    let dayOfWeek = dayModel.dayOfWeek
                    let dayType = dayModel.supplementaryJSON
                    let dutyName = duty.name
                    let dutyDescription = duty.description
                    let locationName = location.name
                    let locationDescription = location.description
                    
                    let dutiesData = AdminDutiesDataRes.init(
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


        //Endpoint that returns all shifts within the ShiftAvailabilitystatus view given a specific date range
        struct AdminShiftAvailabilityStatusDataRes : Content, Hashable {
            var shiftExternalIDText : String
            var startTime : String
            var endTime : String
            var day : Date
            var dayOfWeek : Int?
            var dayType : OptionalSupplementaryJSON
            var dutyName : String
            var dutyDescription : String
            var locationName : String
            var locationDescription : String
            var fullfilledStatus: String

            func hash(into hasher: inout Hasher) {
                hasher.combine(shiftExternalIDText)
            }

            static func ==(lhs: AdminShiftAvailabilityStatusDataRes, rhs: AdminShiftAvailabilityStatusDataRes) -> Bool {
                return lhs.shiftExternalIDText == rhs.shiftExternalIDText
            }
        }
        
        struct AdminShiftAvailabilityStatusDataReq : Content {
            var from : Date // Date from which you want to start seeking UserShifts
            var through : Date // Amount of UserShifts you want to be returned after the from date
        }
        
        adminProtected.post("adminPanel", "shiftAvailabilityStatus", "data"){ req async throws -> [AdminShiftAvailabilityStatusDataRes] in
            let dutiesDataReq = try req.content.decode(AdminShiftAvailabilityStatusDataReq.self)

            let shiftAvailabilityStatuses = try await ShiftAvailabilityStatus.query(on: req.db)
              .join(Day.self, on: \ShiftAvailabilityStatus.$shiftDayID.$id == \Day.$id)
              .filter(Day.self, \.$day >= dutiesDataReq.from)
              .filter(Day.self, \.$day <= dutiesDataReq.through)
              .join(Position.self, on: \ShiftAvailabilityStatus.$shiftPositionID.$id == \Position.$id)
              .join(Location.self, on: \Position.$location.$id == \Location.$id)
              .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
              .all()

            // Use a set to only have one shift instance.
            var dutiesDataRes = Set<AdminShiftAvailabilityStatusDataRes>()

            for shiftAvailabilityStatus in shiftAvailabilityStatuses {
                let dayModel = try shiftAvailabilityStatus.joined(Day.self)
                let location = try shiftAvailabilityStatus.joined(Location.self)
                let duty = try shiftAvailabilityStatus.joined(Duty.self)
                
                let startTime = shiftAvailabilityStatus.shiftStartTime
                let endTime = shiftAvailabilityStatus.shiftEndTime
                let day = dayModel.day
                let dayOfWeek = dayModel.dayOfWeek
                let dayType = dayModel.supplementaryJSON
                let dutyName = duty.name
                let dutyDescription = duty.description
                let locationName = location.name
                let locationDescription = location.description
                let fullfilledStatus = shiftAvailabilityStatus.fulfilledStatus
                let shiftExternalIDText = shiftAvailabilityStatus.shiftExternalIDText
                
                let dutiesData = AdminShiftAvailabilityStatusDataRes.init(
                  shiftExternalIDText: shiftExternalIDText,
                  startTime: startTime,
                  endTime: endTime,
                  day: day,
                  dayOfWeek: dayOfWeek, // Unused calls /calender/data
                  dayType: dayType, // Unused
                  dutyName: dutyName,
                  dutyDescription: dutyDescription, // Unused
                  locationName: locationName,
                  locationDescription: locationDescription, // Unused
                  fullfilledStatus: fullfilledStatus
                )

                dutiesDataRes.insert(dutiesData)
            }

            return Array(dutiesDataRes) // Sets do not conform to response struct.
        }
        
        //Endpoint that returns all the users that are assigned a specific shift

        struct AdminShiftUsersDataRes : Content {
            var externalIDText : String
            var firstName : String
            var lastName : String
            var email : String
        }
        
        struct AdminShiftUsersDataReq : Content {
            var shiftExternalIDText : String
        }
        
        adminProtected.post("adminPanel", "shiftUsers", "data"){ req async throws -> [AdminShiftUsersDataRes] in
            let dutiesDataReq = try req.content.decode(AdminShiftUsersDataReq.self)
            var dutiesDataRes = [AdminShiftUsersDataRes]()

            let userShifts = try await UserShifts.query(on: req.db)
              .join(Shift.self, on: \UserShifts.$shift.$id == \Shift.$id)
              .filter(Shift.self, \Shift.$externalIDText == dutiesDataReq.shiftExternalIDText)
              .join(User.self, on: \UserShifts.$user.$id == \User.$id)
              .all()
            
            for userShift in userShifts {
                let user = try userShift.joined(User.self)

                guard let userID = user.id else { // TODO: remove because unused and querry forces it to be in the database, with an id.
                    app.logger.warning("User does not have id field.")
                    throw Abort(.unauthorized, reason: "User does not have id field")
                }

                let externalIDText = user.externalIDText! // todo: guard let
                let firstName = user.firstName
                let lastName = user.lastName
                let email = user.email

                let dutiesData = AdminShiftUsersDataRes.init(
                  externalIDText: externalIDText,
                  firstName: firstName,
                  lastName: lastName,
                  email: email
                )
                
                dutiesDataRes.append(dutiesData)

            }
            return dutiesDataRes
        }

        
        
        //Endpoint that returns all the users that have matching availability for a specific shift using UsersWithMatchingAvailabilityForShift view

        struct AdminUsersWithMatchingAvailabilityForShiftDataRes : Content {
            var externalIDText : String
            var firstName : String
            var lastName : String
            var email : String
        }
        
        struct AdminUsersWithMatchingAvailabilityForShiftDataReq : Content {
            var shiftExternalIDText : String
        }
        
        adminProtected.post("adminPanel", "usersWithMatchingAvailabilityForShift", "data"){ req async throws -> [AdminUsersWithMatchingAvailabilityForShiftDataRes] in
            let dutiesDataReq = try req.content.decode(AdminUsersWithMatchingAvailabilityForShiftDataReq.self)
            var dutiesDataRes = [AdminUsersWithMatchingAvailabilityForShiftDataRes]()
            

            let usersWithMatchingAvailabilityForShift = try await UsersWithMatchingAvailabilityForShift.query(on: req.db)
              .join(User.self, on: \UsersWithMatchingAvailabilityForShift.$userID == \User.$id)
              .join(Shift.self, on: \UsersWithMatchingAvailabilityForShift.$shiftID == \Shift.$id)
              .filter(Shift.self, \.$externalIDText == dutiesDataReq.shiftExternalIDText)
              .all()

            
            for userMatch in usersWithMatchingAvailabilityForShift {
                let user = try userMatch.joined(User.self)

                guard let userID = user.id else {
                    app.logger.warning("User does not have id field.")
                    throw Abort(.unauthorized, reason: "User does not have id field")
                }

                let externalIDText = user.externalIDText! // todo: guard let
                let firstName = user.firstName
                let lastName = user.lastName
                let email = user.email

                let dutiesData = AdminUsersWithMatchingAvailabilityForShiftDataRes.init(
                  externalIDText: externalIDText,
                  firstName: firstName,
                  lastName: lastName,
                  email: email
                )
                
                dutiesDataRes.append(dutiesData)

            }
            return dutiesDataRes
        }
        
        //Endpoint that adds a shift to a user
        struct AdminAddShiftReq : Content {
            var shiftExternalIDText : String
            var userExternalIDText : String
        }

        enum AdminAddShiftError : Error {
            case noUserFound(userExternalIDText: String)
            case noShiftFound(shiftExternalIDText: String)
        }
        
        adminProtected.post("adminPanel", "addShift") { req async throws in
            let addShiftReq = try req.content.decode(AdminAddShiftReq.self)

            guard let userWithMatchingID = try await User.query(on: req.db)
                    .filter(User.self, \.$externalIDText == addShiftReq.userExternalIDText)
                    .first()
            else {
                throw AdminAddShiftError.noUserFound(userExternalIDText: addShiftReq.userExternalIDText)
            }

            guard let shiftWithMatchingID = try await Shift.query(on: req.db)
                    .filter(Shift.self, \.$externalIDText == addShiftReq.shiftExternalIDText)
                    .first()
            else {
                throw AdminAddShiftError.noShiftFound(shiftExternalIDText: addShiftReq.shiftExternalIDText)
            }
            
            let userShift = UserShifts()
            userShift.$user.id = userWithMatchingID.id!
            userShift.$shift.id = shiftWithMatchingID.id!

            try await userShift.create(on: req.db)

            return true
        }
        
        

        struct CustomError: Content {
            let error: String
        }
    }
}
