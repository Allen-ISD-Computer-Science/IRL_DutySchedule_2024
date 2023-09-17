import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Context: Model, Content {
    static let schema = "Contexts"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "supplementaryJSON")
    var supplementaryJSON: Data

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }
}
