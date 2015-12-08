//
//  Created by Christopher Trott on 12/9/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

protocol ListViewModelable {
    typealias ViewModelType
    
    var viewModels: [ViewModelType] { get }
}

extension ListViewModelable {
    func numberOfRowsInSection(section: Int) -> Int {
        if (section > 0) { return 0 }
        return viewModels.count
    }
    
    func viewModelAtIndexPath(indexPath: NSIndexPath) -> ViewModelType {
        precondition(indexPath.section == 0)
        return viewModels[indexPath.row]
    }
}

enum GroupChange {
    case Reload
    case NoOp
}

enum SingleChange {
    case Insert(NSIndexPath)
    case Delete(NSIndexPath)
    case Reload(NSIndexPath)
    case NoOp
}