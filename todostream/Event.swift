//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import Result

enum Event {
    
    // Model
    case ReqReadTodos
    case ResTodos(Result<[Todo], NSError>)

    case ReqWriteTodo(Todo)    
    case ResTodo(Result<Todo, NSError>)
    
    // ViewModel
    case ReqTodoViewModels
    case ResTodoViewModels(Result<[TodoViewModel], NSError>)
    
    case ResTodoViewModel(Result<TodoViewModel, NSError>)
    
    case ReqAddRandomTodoViewModel
    
//    case ReqTodoDetailViewModel(TodoViewModel)
//    case ResTodoDetailViewModel(Result<TodoDetailViewModel, NSError>)
}