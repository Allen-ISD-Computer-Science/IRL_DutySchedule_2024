import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Locations: Model, Content {
    static let schema = "Locations"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "contextID", generatedBy: .database)
    var contextID: Int?
    
    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }

    init(id: Int? = nil, externalID: UUID? = nil, contextID: Int? = nil, name: String, description: String, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.contextID = contextID
        self.name = name
        self.description = description
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }
}
