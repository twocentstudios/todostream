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

final class ModelServer {
    let configuration: Realm.Configuration
    
    var database: Result<Realm, NSError> {
        return Realm.result(configuration)
    }
    
    init(configuration: Realm.Configuration, appContext: AppContext) {
        self.configuration = configuration
        
        /// .RequestReadTodos
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .filter { if case .RequestReadTodos = $0 { return true }; return false }
            .map { _ in self.database.map { $0.objects(TodoObject).sorted("createdAt", ascending: false).decodeResults() }.mapError { $0 } }
            .map { Event.ResponseTodos($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestWriteTodo
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Todo? in if case let .RequestWriteTodo(todo) = event { return todo }; return nil }
            .ignoreNil()
            .map { $0.realmObject }
            .map { todoObject in
                return self.database
                    .flatMap { realm in
                        realm.writeObject(todoObject).map { $0.domainObject }
                    }
                    .mapError { $0 }
            }
            .map { Event.ResponseTodo($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
    }
}

extension Realm {
    static func result(configuration: Configuration) -> Result<Realm, NSError> {
        do {
            let realm = try Realm(configuration: configuration)
            return Result(value: realm)
        } catch let error as NSError {
            return Result(error: error)
        }
    }
    
    func writeObject<T: Object>(object: T) -> Result<T, NSError> {
        do {
            try self.write {
                self.add(object, update: true)
            }
            return Result(value: object)
        } catch let error as NSError {
            return Result(error: error)
        }
    }
}

extension Results where T: RealmDecodable {
    func decodeResults() -> [T.DomainObjectType] {
        return Array(self).map { obj -> T.DomainObjectType in obj.domainObject }
    }
}