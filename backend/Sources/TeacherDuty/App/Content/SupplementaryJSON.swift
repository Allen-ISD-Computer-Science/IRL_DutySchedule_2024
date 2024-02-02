import Vapor

public typealias Key = String
public typealias SupplementaryJSON = [Key: String]
public typealias OptionalSupplementaryJSON = SupplementaryJSON?

extension SupplementaryJSON {
    enum SupplementaryJSONError: Error {
        case keyNotFound(_ key: String)
        case keyCannotCast(to: LosslessStringConvertible.Type)
    }

    func has(_ key: Key) -> Bool {
        return self[key] != nil
    }

    func isType(key: Key, type: LosslessStringConvertible.Type) -> Bool {
        guard let _ = try? asType(key: key, type) else { // Will also fail if key not found
            return false
        }

        return true
    }

    func asType<T: LosslessStringConvertible>(key: Key, _ type: T.Type) throws -> T {
        guard let value = self[key] else {
            throw SupplementaryJSONError.keyNotFound(key)
        }

        guard let typedValue = type.init(value) else {
            throw SupplementaryJSONError.keyCannotCast(to: type)
        }

        return typedValue
    }
}

struct SupplementaryJSONContent: Content {
    let supplementaryJSON: SupplementaryJSON
}

struct OptionalSupplementaryJSONContent: Content {
    let supplementaryJSON: OptionalSupplementaryJSON
}
