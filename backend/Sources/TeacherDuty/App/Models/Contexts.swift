import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Contexts: Model, Content {
    static let schema = "Contexts"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Field(key: "name")
    var name: String
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }

    init(id: Int? = nil, externalID: UUID? = nil, name: String, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.name = name
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }
}
