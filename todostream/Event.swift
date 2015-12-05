//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import Result

enum Event {
    case ReqReadTodos
    case ReqWriteTodo(Todo)
    
    case ResTodos(Result<[Todo], NSError>)
    case ResTodo(Result<Todo, NSError>)
}