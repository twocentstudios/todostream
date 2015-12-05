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
    dynamic var favorited: Bool = false
    dynamic var priority: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension Todo: RealmEncodable {
    var realmObject: TodoObject {
        let object = TodoObject()
        object.id = self.id
        object.title = self.title
        object.subtitle = self.subtitle
        object.favorited = self.favorited
        object.priority = self.priority
        return object
    }
}

extension TodoObject: RealmDecodable {
    var domainObject: Todo {
        return Todo(
            id: self.id!,
            title: self.title!,
            subtitle: self.subtitle!,
            favorited: self.favorited,
            priority: TodoPriority(rawValue: self.priority!)!,
        )
    }
}