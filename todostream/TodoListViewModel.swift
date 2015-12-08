//
//  Created by Christopher Trott on 12/9/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

struct TodoListViewModel: ListViewModelable {
    var viewModels = [TodoViewModel]()
    
    mutating func incorporateTodoViewModels(newViewModels: [TodoViewModel]) -> GroupChange {
        if (viewModels == newViewModels) { return .NoOp }
        viewModels = newViewModels
        return .Reload
    }
    
    mutating func incorporateTodoViewModel(newViewModel: TodoViewModel) -> SingleChange {
        if let index = viewModels.indexOf(newViewModel) {
            if (newViewModel.deleted) {
                // delete
                viewModels.removeAtIndex(index)
                return .Delete(NSIndexPath(forRow: index, inSection: 0))
            } else {
                // replace
                viewModels[index] = newViewModel
                return .Reload(NSIndexPath(forRow: index, inSection: 0))
            }
        } else {
            viewModels.insert(newViewModel, atIndex: 0)
            return .Insert(NSIndexPath(forRow: 0, inSection: 0))
        }
    }
}
