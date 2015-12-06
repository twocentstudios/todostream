//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import Result

enum Event {
    
    // Model
    case RequestReadTodos
    case ResponseTodos(Result<[Todo], NSError>)

    case RequestWriteTodo(Todo)
    case ResponseTodo(Result<Todo, NSError>)
    
    // ViewModel
    case RequestTodoViewModels
    case ResponseTodoViewModels(Result<[TodoViewModel], NSError>)
    
    case ResponseTodoViewModel(Result<TodoViewModel, NSError>)
    
    case RequestAddRandomTodoViewModel
    
    case RequestDeleteTodoViewModel(TodoViewModel)
    
    case RequestNewTodoDetailViewModel
    case RequestTodoDetailViewModel(TodoViewModel)
    case ResponseTodoDetailViewModel(Result<TodoDetailViewModel, NSError>)
    
    case RequestUpdateDetailViewModel(TodoDetailViewModel)
    case ResponseUpdateDetailViewModel(Result<TodoDetailViewModel, NSError>)
}