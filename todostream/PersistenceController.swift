//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa
import Result

protocol RealmEncodable {
    typealias RealmObjectType: Object
    var realmObject: RealmObjectType { get }
}

protocol RealmDecodable {
    typealias DomainObjectType
    var domainObject: DomainObjectType { get }
}

enum PersistenceError: ErrorType {
    case UnknownError
    case RealmError(NSError)
}

final class PersistenceController {
    let configuration: Realm.Configuration
    
    var disposables = [Disposable?]()
    
    var database: Result<Realm, PersistenceError> {
        return Realm.result(configuration)
    }
    
    init(configuration: Realm.Configuration, appContext: AppContext) {
        self.configuration = configuration
        
        /// .RequestReadTodos
        disposables += appContext.eventsSignal
            .filter { if case .RequestReadTodos = $0 { return true }; return false }
            .map { _ in self.database.map { $0.objects(TodoObject).sorted("createdAt", ascending: false).decodeResults() }.mapError { _ in NSError.app() } }
            .map { Event.ResponseTodos($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestWriteTodo
        disposables += appContext.eventsSignal
            .map { event -> Todo? in if case let .RequestWriteTodo(todo) = event { return todo }; return nil }
            .ignoreNil()
            .map { $0.realmObject }
            .map { todoObject in
                return self.database
                    .flatMap { realm in
                        realm.writeObject(todoObject).map { $0.domainObject }
                    }
                    .mapError { _ in NSError.app() }
            }
            .map { Event.ResponseTodo($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
    }
}

extension Realm {
    static func result(configuration: Configuration) -> Result<Realm, PersistenceError> {
        do {
            let realm = try Realm(configuration: configuration)
            return Result(value: realm)
        } catch let error as NSError {
            return Result(error: .RealmError(error))
        }
    }
    
    func writeObject<T: Object>(object: T) -> Result<T, PersistenceError> {
        do {
            try self.write {
                self.add(object, update: true)
            }
            return Result(value: object)
        } catch let error as NSError {
            return Result(error: .RealmError(error))
        }
    }
}

extension Results where T: RealmDecodable {
    func decodeResults() -> [T.DomainObjectType] {
        return Array(self).map { obj -> T.DomainObjectType in obj.domainObject }
    }
}