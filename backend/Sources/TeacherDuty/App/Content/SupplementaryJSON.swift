import Vapor
import Foundation
import Fluent

public typealias Key = String
public typealias SupplementaryJSON = [Key: SupplementaryAny]
public typealias OptionalSupplementaryJSON = SupplementaryJSON?

public enum SupplementaryAny: Codable {
    case string(String), int(Int), array([SupplementaryAny]), dictionary(SupplementaryJSON)

    // Custom decoder to decode types into enums.
    public init(from decoder: Decoder) throws { // TODO fix this... must be a simpler way.
        if let container = try? decoder.singleValueContainer() {
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }

            if let value = try? container.decode(Int.self) {
                self = .int(value)
                return
            }


            if let value = try? container.decode(SupplementaryJSON.self) {
                self = .dictionary(value)
                return
            }
        }

        if var container = try? decoder.unkeyedContainer() {
            var input = [SupplementaryAny]()

            while !container.isAtEnd {
                input.append(try container.decode(SupplementaryAny.self))
            }
            self = .array(input)
            return
        }

        throw SupplementaryAnyError.noDecoderTypeFound
    }

    // Customer encoder to inline.
    public func encode(to encoder: Encoder) throws {  // TODO fix this... must be a simpler way. maybe use switch.
        if case .array(let value) = self {
            var unkeyedContainer = encoder.unkeyedContainer()

            try unkeyedContainer.encode(value)
            return
        }


        var singleValueContainer = encoder.singleValueContainer()

        if case .string(let string) = self {
            try singleValueContainer.encode(string)
            return
        }

        if case .dictionary(let dictionary) = self {
            try singleValueContainer.encode(dictionary)
            return
        }

        throw SupplementaryAnyError.noEncoderTypeFound
    }


    enum SupplementaryAnyError: Error {
        case noDecoderTypeFound
        case noEncoderTypeFound
    }
}


extension SupplementaryJSON {
    enum SupplementaryJSONError: Error {
        case keyNotFound(_ key: String)
        case notString(_ key: String)
        case valueCannotCast(from: String, to: LosslessStringConvertible.Type)
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

        guard case .string(let stringValue) = value else {
            throw SupplementaryJSONError.notString(key)
        }

        guard let typedValue = type.init(stringValue) else {
            throw SupplementaryJSONError.valueCannotCast(from: stringValue, to: type)
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
