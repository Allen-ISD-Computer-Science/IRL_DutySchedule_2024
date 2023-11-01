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
            var shiftID : String
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
        
        adminProtected.get("adminPanel", "duties", "all") { req async throws -> [AdminDutiesDataRes] in
            var dutiesDataRes = [AdminDutiesDataRes]()

            let shifts = try await Shift.query(on: req.db)
              .join(Day.self, on: \Shift.$day.$id == \Day.$id)
              .join(Position.self, on: \Shift.$position.$id == \Position.$id)
              .all()

            for shift in shifts {
            
                let shiftDutyLoc = try await Position.query(on: req.db)
                  .join(Duty.self, on: \Position.$duty.$id == \Duty.$id)
                  .join(Location.self, on: \Position.$location.$id == \Location.$id)
                  .filter(Position.self, \.$id == shift.$position.id)
                  .first()
                
                let shiftModel = try shift.joined(Shift.self)
                let position = try shift.joined(Position.self)
                let dayModel = try shift.joined(Day.self)
                let location = try shiftDutyLoc!.joined(Location.self)
                let duty = try shiftDutyLoc!.joined(Duty.self)

                let shiftID = shiftModel.externalIDText
                let startTime = shiftModel.start
                let endTime = shiftModel.end
                let day = dayModel.day
                let dayOfWeek = dayModel.dayOfWeek
                let dayType = dayModel.supplementaryJSON
                let dutyName = duty.name
                let dutyDescription = duty.description
                let locationName = location.name
                let locationDescription = location.description
                
                let dutiesData = AdminDutiesDataRes.init(
                  shiftID: shiftID!,
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
        
        print("Admin Duties Data Count: \(dutiesDataRes.count)")
        return dutiesDataRes
        
    }
    
    struct CustomError: Content {
        let error: String
    }
    }
}
