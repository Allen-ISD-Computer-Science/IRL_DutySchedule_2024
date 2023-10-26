import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Role: Model, Content {
    static let schema = "Roles"

    private static func getFirstRoleSK(key: Key, on database: Database) async throws -> Role {
        guard let role = try await Role.query(on: database).all().first(where: { $0.supplementaryJSON?.has(key) ?? false }) else {
            throw Abort(.internalServerError, reason: "Failed when locating role with \(key).")
        }

        return role
    }

    static func defaultRole(on database: Database) async throws -> Role {
        return try await getFirstRoleSK(key: "default", on: database)
    }

    static func adminRole(on database: Database) async throws -> Role {
        return try await getFirstRoleSK(key: "admin", on: database)
    }

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var context: Context
    
    @Field(key: "role")
    var role: String

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?

    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}

extension Role: Contextable {
    static let contextKey = \Role.$context.$id
}
