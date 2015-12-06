//
//  Created by Christopher Trott on 12/7/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import ReactiveCocoa

extension SignalType {
    /// Returns a signal that forward events until the supplied block returns nil.
    @warn_unused_result(message="Did you forget to call `observe` on the signal?")
    public func takeUntilNil<T>(block: () -> T?) -> Signal<Value, Error> {
        return Signal { observer in
            return self.observe { event in
                let blockValue = block()

                if (blockValue == nil) {
                    observer.sendCompleted()
                } else {
                    observer.action(event)
                }
            }
        }
    }
}