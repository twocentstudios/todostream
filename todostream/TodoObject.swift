//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import RealmSwift

final class TodoObject: Object {
    dynamic var id: String?
    dynamic var title: String?
    dynamic var subtitle: String?
    dynamic var complete: Bool = false
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
        object.title = self.title
        object.subtitle = self.subtitle
        object.complete = self.complete
        object.priority = self.priority.rawValue
        object.deleted = self.deleted
        return object
    }
}

extension TodoObject: RealmDecodable {
    var domainObject: Todo {
        return Todo(
            id: NSUUID(UUIDString: self.id!)!,
            title: self.title!,
            subtitle: self.subtitle!,
            complete: self.complete,
            priority: TodoPriority(rawValue: self.priority!)!,
            deleted: self.deleted
        )
    }
}