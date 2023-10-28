import Foundation
import Vapor
import Fluent

// This is a bit different form others because of the need for multi-property, see https://github.com/vapor/vapor/issues/1819
struct ShiftSchedule {

    struct Result {
        let conflictsWith: [UserShifts]
    }

    static func testConflict(request: Request, user: User, newShift: UserShifts) async throws -> Result {
        guard user.id == newShift.$user.id else {
            throw Abort(.conflict, reason: "User id is not matching with newShift.")
        }

        guard let userId = user.id else {
            throw Abort(.internalServerError, reason: "User Id does not exist in the database.")
        }

        let shift = try await newShift.$shift.get(on: request.db)

        let possibleShifts = try await UserShifts.query(on: request.db)
          .with(\.$shift)
          .filter(\.user.$id == userId) // Filter to only this user.
          .filter(\.shift.$day.$id == shift.$day.id) // Filter all out not on same day
          .all()

        let conflicts = try possibleShifts.filter { possibleShift in
          try Time.intersectsExclusively(lhsStartTime: possibleShift.shift.start, lhsEndTime: possibleShift.shift.end, rhsStartTime: shift.start, rhsEndTime: shift.end)
        }

        return Result(conflictsWith: conflicts)
    }
}
