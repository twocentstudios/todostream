//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct Todo {
    let id: NSUUID
    let createdAt: NSDate
    var title: String = ""
    var subtitle: String = ""
    var completedAt: NSDate? = nil
    var priority: TodoPriority = .Normal
    var deleted: Bool = false
    
    var complete: Bool {
        return completedAt != nil
    }

    // New
    init() {
        self.id = NSUUID()
        self.createdAt = NSDate()
    }
    
    // Decoded
    init(id: NSUUID, createdAt: NSDate, title: String, subtitle: String, completedAt: NSDate?, priority: TodoPriority, deleted: Bool) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.subtitle = subtitle
        self.completedAt = completedAt
        self.priority = priority
        self.deleted = deleted
    }
}

enum TodoPriority: String {
    case High
    case Normal
}

extension Todo: Equatable {}
func ==(lhs: Todo, rhs: Todo) -> Bool {
    return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.createdAt == rhs.createdAt &&
        lhs.subtitle == rhs.subtitle &&
        lhs.completedAt == rhs.completedAt &&
        lhs.priority == rhs.priority &&
        lhs.deleted == lhs.deleted
}