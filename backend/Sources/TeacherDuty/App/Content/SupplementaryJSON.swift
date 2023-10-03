import Vapor

public typealias Key = String
public typealias SupplementaryJSON = [Key: String]
public typealias OptionalSupplementaryJSON = SupplementaryJSON?

extension SupplementaryJSON {
    func has(_ key: Key) -> Bool {
        return self[key] != nil
    }

    func isBool(_ key: Key) -> Bool {
        guard has(key), let value = self[key] else {
            return false
        }

        return Bool(value) != nil
    }

    func asBool(_ key: Key) -> Bool {
        return Bool(self[key]!)!
    }

    func isInt(_ key: Key) -> Bool {
        guard has(key), let value = self[key] else {
            return false
        }

        return Int(value) != nil
    }

    func asInt(_ key: Key) -> Int {
        return Int(self[key]!)!
    }
}

struct SupplementaryJSONContent: Content {
    let supplementaryJSON: SupplementaryJSON
}

struct OptionalSupplementaryJSONContent: Content {
    let supplementaryJSON: OptionalSupplementaryJSON
}
