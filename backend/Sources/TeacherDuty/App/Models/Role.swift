import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Role: Model, Content {
    static let schema = "Roles"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "contextID")
    var context: Context
    
    @Field(key: "role")
    var role: String

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: Data

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?

    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }
}
