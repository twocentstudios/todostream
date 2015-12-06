//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

struct TodoListViewModel {
    
    init(appContext: AppContext) {
        
        /// .RequestTodoViewModels
        appContext.eventsSignal
            .filter { event -> Bool in
                switch event {
                case .RequestTodoViewModels: return true
                default: return false
                }
            }
            .map { _ in Event.RequestReadTodos }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodos
        appContext.eventsSignal
            .map { event -> Result<[Todo], NSError>? in
                switch event {
                case .ResponseTodos(let result): return result
                default: return nil
                }
            }
            .ignoreNil()
            .map { result -> Result<[TodoViewModel], NSError> in
                return result
                    .map { todos in
                        todos.map { (todo: Todo) -> TodoViewModel in TodoViewModel(todo: todo) }
                    }
                    .mapError { _ in NSError.app() } // TODO: map model error to view model error
            }
            .map { Event.ResponseTodoViewModels($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodo
        appContext.eventsSignal
            .map { event -> Result<Todo, NSError>? in
                switch event {
                case .ResponseTodo(let result): return result
                default: return nil
                }
            }
            .ignoreNil()
            .map { result -> Result<TodoViewModel, NSError> in
                return result
                    .map { todo in TodoViewModel(todo: todo) }
                    .mapError { _ in NSError.app() } // TODO: map model error to view model error
            }
            .map { Event.ResponseTodoViewModel($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestAddRandomTodoViewModel
        appContext.eventsSignal
            .filter { event -> Bool in
                switch event {
                case .RequestAddRandomTodoViewModel: return true
                default: return false
                }
            }
            .map { _ in
                var todo = Todo()
                todo.title = todo.id.UUIDString
                return Event.RequestWriteTodo(todo)
            }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
    }
}

struct TodoViewModel {
    let todo: Todo
    
    let title: String
    let subtitle: String
    let complete: Bool
    
    init(todo: Todo) {
        self.todo = todo
        
        let priority = todo.priority.rawValue.uppercaseString
        
        self.title = todo.title
        self.subtitle = "Priority: \(priority)"
        self.complete = todo.complete
    }
}

extension TodoViewModel: Equatable {}
func ==(lhs: TodoViewModel, rhs: TodoViewModel) -> Bool {
    return lhs.todo == rhs.todo
}
