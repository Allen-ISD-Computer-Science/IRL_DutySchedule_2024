import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Location: Model, Content {
    static let schema = "Locations"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Parent(key: "condextID")
    var contextID: Context
    
    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}
