import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Shifts: Model, Content {
    static let schema = "Shifts"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "dayID", generatedBy: .database)
    var dayID: Int?

    @ID(custom: "positionID", generatedBy: .database)
    var positionID: Int?

    @Field(key: "startTime")
    //var startTime: TIME
    
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }
/*
    init(id: Int? = nil, externalID: UUID? = nil, name: String, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.name = name
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }*/
}
