import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Days: Model, Content {
    static let schema = "Days"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "contextID", generatedBy: .database)
    var contextID: Int?
    
    @Field(key: "supplementaryJSON")
    var supplementaryJSON: JSONData?
   
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }

    init(id: Int? = nil, externalID: UUID? = nil, contextID: Int? = nil, supplementaryJSON: JSONData? = nil, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.contextID = contextID
        self.supplementaryJSON = supplementaryJSON
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }

    struct JSONData: Codable {
        var name: String
        var age: Int
    }
}
