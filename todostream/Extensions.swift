//
//  Created by Christopher Trott on 12/7/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import ReactiveCocoa

public func +=<Element>(inout lhs: [Element], rhs: Element) {
    return lhs.append(rhs)
}

// TODO: turn this into an extension on SequenceType
func dispose(disposables: [Disposable?]) {
    disposables.forEach { $0?.dispose() }
}