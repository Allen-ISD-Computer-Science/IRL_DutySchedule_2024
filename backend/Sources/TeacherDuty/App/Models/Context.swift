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

    @OptionalField(key: "supplementaryJSON")
    var supplementaryJSON: OptionalSupplementaryJSON

    @Timestamp(key: "creationTimestamp", on: .create, format: .default)
    var creationTimestamp: Date?
    
    @Timestamp(key: "modificationTimestamp", on: .update)
    var modificationTimestamp: Date?

    init() { }
}

public protocol Contextable: Model {
    static var contextKey: KeyPath<Self, FieldProperty<Self, Int>> { get }
}

// Add fields to all contextable.
extension Contextable {
    var _contextId: FieldProperty<Self, Int> {
        self[keyPath: Self.contextKey]
    }
}

extension QueryBuilder where Model: Contextable {
    func context<Foreign>(_ context: Foreign.Type) -> Self
      where Foreign: Contextable {
        return self.filter(\Model._contextId == \Foreign._contextId)
    }

    func context(with context: Int) -> Self {
        return self.filter(\Model._contextId == context)
    }
}
