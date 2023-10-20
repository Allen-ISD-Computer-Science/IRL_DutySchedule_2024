import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class UserRoles: Model, Content {
    static let schema = "UserRoles"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "externalIDText", generatedBy: .database)
    var externalIDText: String?
    
    @Parent(key: "userID")
    var user: User

    @Parent(key: "roleID")
    var role: Role

    @Timestamp(key: "creationTimestamp", on: .create)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }

}
