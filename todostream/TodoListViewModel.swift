//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

final class TodoListViewModel {
    
    init(appContext: AppContext) {
        
        /// .RequestTodoViewModels
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .filter { if case .RequestTodoViewModels = $0 { return true }; return false }
            .map { _ in Event.RequestReadTodos }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodos
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Result<[Todo], NSError>? in if case let .ResponseTodos(result) = event { return result }; return nil }
            .ignoreNil()
            .map { result -> Result<[TodoViewModel], NSError> in
                return result
                    .map { todos in
                        todos
                            .filter { !$0.deleted }
                            .map { (todo: Todo) -> TodoViewModel in TodoViewModel(todo: todo) }
                    }
                    .mapError { $0 } // TODO: map model error to view model error
            }
            .map { Event.ResponseTodoViewModels($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseTodo
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Result<Todo, NSError>? in if case let .ResponseTodo(result) = event { return result }; return nil }
            .ignoreNil()
            .map { result -> Result<TodoViewModel, NSError> in
                return result
                    .map { todo in TodoViewModel(todo: todo) }
                    .mapError { $0 } // TODO: map model error to view model error
            }
            .map { Event.ResponseTodoViewModel($0) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestToggleCompleteTodoViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> TodoViewModel? in if case let .RequestToggleCompleteTodoViewModel(todoViewModel) = event { return todoViewModel }; return nil }
            .ignoreNil()
            .map {
                var todo = $0.todo
                todo.completedAt = todo.complete ? nil : NSDate()
                return Event.RequestWriteTodo(todo)
            }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestDeleteTodoViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> TodoViewModel? in if case let .RequestDeleteTodoViewModel(todoViewModel) = event { return todoViewModel }; return nil }
            .ignoreNil()
            .map {
                var todo = $0.todo
                todo.deleted = true
                return Event.RequestWriteTodo(todo)
            }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestNewTodoDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .filter { if case .RequestNewTodoDetailViewModel = $0 { return true }; return false }
            .map { _ in
                let todo = Todo()
                let todoDetailViewModel = TodoDetailViewModel(todo: todo)
                return todoDetailViewModel
            }
            .map { Event.ResponseTodoDetailViewModel(Result(value: $0)) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestTodoDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> TodoViewModel? in if case let .RequestTodoDetailViewModel(todoViewModel) = event { return todoViewModel }; return nil }
            .ignoreNil()
            .map {
                let todo = $0.todo
                let todoDetailViewModel = TodoDetailViewModel(todo: todo)
                return todoDetailViewModel
            }
            .map { Event.ResponseTodoDetailViewModel(Result(value: $0)) }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .RequestUpdateDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> TodoDetailViewModel? in if case let .RequestUpdateDetailViewModel(todoDetailViewModel) = event { return todoDetailViewModel }; return nil }
            .ignoreNil()
            .map { $0.validate() }
            .map { (result: Result<TodoDetailViewModel, NSError>) -> Event in
                let saveableResult = result.map { (todoDetailViewModel: TodoDetailViewModel) -> TodoDetailViewModel in
                    var saveableViewModel = todoDetailViewModel
                    saveableViewModel.shouldSave = true
                    return saveableViewModel
                }
                return Event.ResponseUpdateDetailViewModel(saveableResult)
            }
            .observeOn(appContext.scheduler)
            .observe(appContext.eventsObserver)
        
        /// .ResponseUpdateDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Result<TodoDetailViewModel, NSError>? in if case let .ResponseUpdateDetailViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .map { $0.value }
            .ignoreNil()
            .filter { $0.shouldSave }
            .map {
                return Event.RequestWriteTodo($0.updatedTodo)
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
