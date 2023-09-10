import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Roles: Model, Content {
    static let schema = "Roles"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "contextID", generatedBy: .database)
    var contextID: Int?
    
    @Field(key: "role")
    var role: String
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }

    init(id: Int? = nil, externalID: UUID? = nil, contextID: Int? = nil, role: String, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.contextID = contextID
        self.role = role
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }
}
