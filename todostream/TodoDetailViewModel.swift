//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct TodoDetailViewModel {
    let todo: Todo
    
    var title: String
    var subtitle: String
    var priority: TodoPriority
    var completed: Bool
    var deleted: Bool
    
    let propertyCount = 5
    
    var createdAtString: String {
        return "\(String(todo.createdAt.timeIntervalSinceNow)) seconds ago"
    }
    var completedString: String {
        return completed ? "Uncomplete" : "Complete"
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
    
    func updatedModel() -> Todo {
        var updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.subtitle = subtitle
        updatedTodo.priority = priority
        updatedTodo.deleted = deleted
        updatedTodo.completedAt = completed ? NSDate() : nil
        return updatedTodo
    }
}
