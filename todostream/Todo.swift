//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct Todo {
    let id: NSUUID
    var title: String = ""
    var subtitle: String = ""
    var favorited: Bool = false
    var priority: TodoPriority = .Normal

    // New
    init() {
        self.id = NSUUID()
    }
    
    // Decoded
    init(id: NSUUID, title: String, subtitle: String, favorited: Bool, priority: TodoPriority) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.favorited = favorited
        self.priority = priority
    }
}

enum TodoPriority: String {
    case High
    case Normal
}


