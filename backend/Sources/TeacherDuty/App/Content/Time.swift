import Vapor
import Fluent
import MySQLKit

typealias Time = String

protocol TimeProperty {
    var timeProperty: [Int] { get throws }

    func timeComponet() throws -> DateComponents
}

extension Time: TimeProperty {
    var timeProperty: [Int] {
        get throws {
            guard self.count == 8 else {
                throw Abort(.internalServerError, reason: "Failed to parse timeProperty count.")
            }

            //TODO regex match time. or search that : are in the right place.

            let splitValue = self.split(separator: ":")

            guard splitValue.count == 3 else {
                throw Abort(.internalServerError, reason: "Failed to parse timeProperty split.")
            }

            return try splitValue.map { str in
                guard let int = Int(str) else {
                    throw Abort(.internalServerError, reason: "Failed to parse timeProperty time.")
                }
                return int
            }
        }
    }


    func timeComponet() throws -> DateComponents {
        let time = try timeProperty

        return DateComponents(hour: time[0], minute: time[1], second: time[2])
    }
}
