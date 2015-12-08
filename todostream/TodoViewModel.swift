//
//  Created by Christopher Trott on 12/9/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct TodoViewModel {
    let todo: Todo
    
    let title: String
    let subtitle: String
    let complete: Bool
    let deleted: Bool
    
    var completeActionTitle: String {
        return complete ? "Uncomplete" : "Complete"
    }
    
    init(todo: Todo) {
        self.todo = todo
        
        let priority = todo.priority.rawValue.uppercaseString
        
        self.title = todo.title
        self.subtitle = "Priority: \(priority)"
        self.complete = todo.complete
        self.deleted = todo.deleted
    }
}

// TODO: change this to isEqualIdentity
extension TodoViewModel: Equatable {}
func ==(lhs: TodoViewModel, rhs: TodoViewModel) -> Bool {
    return lhs.todo.id == rhs.todo.id
}
