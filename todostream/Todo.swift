//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct Todo {
    let id: NSUUID
    var title: String = ""
    var subtitle: String = ""
    var complete: Bool = false
    var priority: TodoPriority = .Normal

    // New
    init() {
        self.id = NSUUID()
    }
    
    // Decoded
    init(id: NSUUID, title: String, subtitle: String, complete: Bool, priority: TodoPriority) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.complete = complete
        self.priority = priority
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
        lhs.subtitle == rhs.subtitle &&
        lhs.complete == rhs.complete &&
        lhs.priority == rhs.priority
}