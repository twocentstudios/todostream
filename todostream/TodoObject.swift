//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import RealmSwift

final class TodoObject: Object {
    dynamic var id: String?
    dynamic var createdAt: NSDate?
    dynamic var title: String?
    dynamic var subtitle: String?
    dynamic var completedAt: NSDate? = nil
    dynamic var priority: String?
    dynamic var deleted: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Todo: RealmEncodable {
    var realmObject: TodoObject {
        let object = TodoObject()
        object.id = self.id.UUIDString
        object.createdAt = self.createdAt
        object.title = self.title
        object.subtitle = self.subtitle
        object.completedAt = self.completedAt
        object.priority = self.priority.rawValue
        object.deleted = self.deleted
        return object
    }
}

extension TodoObject: RealmDecodable {
    var domainObject: Todo {
        return Todo(
            id: NSUUID(UUIDString: self.id!)!,
            createdAt: self.createdAt!,
            title: self.title!,
            subtitle: self.subtitle!,
            completedAt: self.completedAt,
            priority: TodoPriority(rawValue: self.priority!)!,
            deleted: self.deleted
        )
    }
}