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
        
    }
    
    struct CustomError: Content {
        let error: String
    }
}
