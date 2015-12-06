//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import Result

struct TodoDetailViewModel {
    let todo: Todo
    
    var updatedTodo: Todo {
        var updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.subtitle = subtitle
        updatedTodo.priority = priority
        updatedTodo.deleted = deleted
        updatedTodo.completedAt = completed ? NSDate() : nil
        return updatedTodo
    }
    
    let propertyCount = 5
    var title: String
    var subtitle: String
    var priority: TodoPriority
    var completed: Bool
    var deleted: Bool
    
    var shouldSave: Bool = false
    
    var createdAtString: String {
        return "\(String(todo.createdAt.timeIntervalSinceNow)) seconds ago"
    }
    var completedString: String {
        return completed ? "Complete" : "Incomplete"
    }
    var priorityString: String {
        return priority.rawValue.uppercaseString
    }
    var deletedString: String {
        return deleted ? "Restore" : "Delete"
    }
    
    mutating func togglePriority() {
        switch priority {
        case .High: self.priority = .Normal
        case .Normal: self.priority = .High
        }
    }
    
    mutating func toggleCompleted() {
        self.completed = !self.completed
    }
    
    mutating func toggleDeleted() {
        self.deleted = !self.deleted
    }
    
    init(todo: Todo) {
        self.todo = todo
        
        self.title = todo.title
        self.subtitle = todo.subtitle
        self.priority = todo.priority
        self.deleted = todo.deleted
        self.completed = todo.complete
    }
    
    func validate() -> Result<TodoDetailViewModel, NSError> {
        if (self.title == "") { return Result(error: NSError.app("Please add a title.")) }
        
        return Result(value: self)
    }
}

extension TodoDetailViewModel: Equatable {}
func ==(lhs: TodoDetailViewModel, rhs: TodoDetailViewModel) -> Bool {
    return lhs.todo == rhs.todo &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.completed == rhs.completed &&
        lhs.priority == rhs.priority &&
        lhs.deleted == lhs.deleted
}
