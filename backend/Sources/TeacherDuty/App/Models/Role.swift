import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Role: Model, Content {
    static let schema = "Roles"
    typealias JSONData = [String: String]

    static func defaultRole(on database: Database) async throws -> Role {
        guard let role = try await Role.query(on: database).all().first(where: { $0.supplementaryJSON["default"] != nil }) else {
            throw Abort(.internalServerError, reason: "Failed when locating default role.")
        }

        return role
    }

    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var context: Context
    
    @Field(key: "role")
    var role: String

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: [String: String]

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?

    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}
