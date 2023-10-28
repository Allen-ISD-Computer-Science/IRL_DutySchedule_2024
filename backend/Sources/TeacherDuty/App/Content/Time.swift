import Vapor
import Fluent
import MySQLKit

typealias Time = String

struct TimeProperty {
    let hour: Int
    let minute: Int
    let second: Int
}

extension Time {
    var timeProperty: TimeProperty {
        get throws {
            guard self.count == 8 else {
                throw Abort(.internalServerError, reason: "Failed to parse timeProperty count.")
            }

            //TODO regex match time. or search that : are in the right place.

            let splitValue = self.split(separator: ":")

            guard splitValue.count == 3 else {
                throw Abort(.internalServerError, reason: "Failed to parse timeProperty split.")
            }

            let timeArray = try splitValue.map { str in
                guard let int = Int(str) else {
                    throw Abort(.internalServerError, reason: "Failed to parse timeProperty time.")
                }
                return int
            }

            return TimeProperty(hour: timeArray[0], minute: timeArray[1], second: timeArray[2])
        }
    }


    func timeComponet() throws -> DateComponents {
        let time = try timeProperty

        return DateComponents(hour: time.hour, minute: time.minute, second: time.second)
    }


    static func intersectsExclusively(lhsStartTime: Time, lhsEndTime: Time, rhsStartTime: Time, rhsEndTime: Time) throws -> Bool {
        let lhsStartProperty = try lhsStartTime.timeProperty
        let lhsEndProperty = try lhsEndTime.timeProperty

        let rhsStartProperty = try rhsStartTime.timeProperty
        let rhsEndProperty = try rhsEndTime.timeProperty

        return intersectsExclusively(lhsStart: lhsStartProperty, lhsEnd: lhsEndProperty, rhsStart: rhsStartProperty, rhsEnd: rhsEndProperty)
    }

    static func intersectsExclusively(lhsStart: TimeProperty, lhsEnd: TimeProperty, rhsStart: TimeProperty, rhsEnd: TimeProperty) -> Bool {
        if lhsStart.hour > rhsEnd.hour ||
           (lhsStart.hour == rhsEnd.hour && lhsStart.minute > rhsEnd.minute) ||
           (lhsStart.hour == rhsEnd.hour && lhsStart.minute == rhsEnd.minute && lhsStart.second >= rhsEnd.second) {
            return false
        }

        if lhsEnd.hour < rhsStart.hour ||
           (lhsEnd.hour == rhsStart.hour && lhsEnd.minute < rhsStart.minute) ||
           (lhsEnd.hour == rhsStart.hour && lhsEnd.minute == rhsStart.minute && lhsEnd.second <= rhsStart.second) {
            return false
        }

        return true
    }
}
