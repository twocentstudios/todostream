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
            .filter { if case .RequestTodoViewModels = $0 { return true }; return false }
            .map { _ in Event.RequestReadTodos }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodos
        appContext.eventsSignal
            .map { event -> Result<[Todo], NSError>? in if case let .ResponseTodos(result) = event { return result }; return nil }
            .ignoreNil()
            .map { result -> Result<[TodoViewModel], NSError> in
                return result
                    .map { todos in
                        todos
                            .filter { !$0.deleted }
                            .map { (todo: Todo) -> TodoViewModel in TodoViewModel(todo: todo) }
                    }
                    .mapError { _ in NSError.app() } // TODO: map model error to view model error
            }
            .map { Event.ResponseTodoViewModels($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodo
        appContext.eventsSignal
            .map { event -> Result<Todo, NSError>? in if case let .ResponseTodo(result) = event { return result }; return nil }
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
            .filter { if case .RequestAddRandomTodoViewModel = $0 { return true }; return false }
            .map { _ in
                var todo = Todo()
                todo.title = todo.id.UUIDString
                return Event.RequestWriteTodo(todo)
            }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestDeleteTodoViewModel
        appContext.eventsSignal
            .map { event -> TodoViewModel? in if case let .RequestDeleteTodoViewModel(todoViewModel) = event { return todoViewModel }; return nil }
            .ignoreNil()
            .map {
                var todo = $0.todo
                todo.deleted = true
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
    let deleted: Bool
    
    init(todo: Todo) {
        self.todo = todo
        
        let priority = todo.priority.rawValue.uppercaseString
        
        self.title = todo.title
        self.subtitle = "Priority: \(priority)"
        self.complete = todo.complete
        self.deleted = todo.deleted
    }
}

extension TodoViewModel: Equatable {}
func ==(lhs: TodoViewModel, rhs: TodoViewModel) -> Bool {
    return lhs.todo == rhs.todo
}
