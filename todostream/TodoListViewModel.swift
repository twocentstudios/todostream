//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

struct TodoListViewModel {
    
    init(appContext: AppContext) {
        
        /// .ReqTodoViewModels
        appContext.eventsSignal
            .filter { event -> Bool in
                switch event {
                case .ReqTodoViewModels: return true
                default: return false
                }
            }
            .map { _ in Event.ReqReadTodos }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResTodos
        appContext.eventsSignal
            .map { event -> Result<[Todo], NSError>? in
                switch event {
                case .ResTodos(let result): return result
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
            .map { Event.ResTodoViewModels($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResTodo
        appContext.eventsSignal
            .map { event -> Result<Todo, NSError>? in
                switch event {
                case .ResTodo(let result): return result
                default: return nil
                }
            }
            .ignoreNil()
            .map { result -> Result<TodoViewModel, NSError> in
                return result
                    .map { todo in TodoViewModel(todo: todo) }
                    .mapError { _ in NSError.app() } // TODO: map model error to view model error
            }
            .map { Event.ResTodoViewModel($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ReqAddRandomTodoViewModel
        appContext.eventsSignal
            .filter { event -> Bool in
                switch event {
                case .ReqAddRandomTodoViewModel: return true
                default: return false
                }
            }
            .map { _ in
                var todo = Todo()
                todo.title = todo.id.UUIDString
                return Event.ReqWriteTodo(todo)
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
