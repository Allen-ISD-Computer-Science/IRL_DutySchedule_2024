import Vapor
import Fluent
import FluentMySQLDriver
import Crypto

final class Positions: Model, Content {
    static let schema = "Positions"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @ID(custom: "externalID", generatedBy: .database)
    var externalID: UUID?

    @ID(custom: "dutyID", generatedBy: .database)
    var dutyID: Int?

    @ID(custom: "locationID", generatedBy: .database)
    var locationID: Int?
       
    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modifcationTimestamp", on: .update, format: .default)
    var modificationTimestamp: Date?

    init() { }

    init(id: Int? = nil, externalID: UUID? = nil, dutyID: Int? = nil, locationID: Int? = nil, creationTimestamp: Date? = nil, modifcationTimestamp: Date? = nil) {
        self.id = id
        self.externalID = externalID
        self.dutyID = dutyID
        self.locationID = locationID
        self.creationTimestamp = creationTimestamp
        self.modificationTimestamp = modifcationTimestamp
    }
}
