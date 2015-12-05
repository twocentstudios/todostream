//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct AppContext {
    let (eventsSignal, eventsObserver) = Signal<Event, NoError>.pipe()
    
    // All events sent to eventsObserver that originate from eventsSignal *must* be
    // posted on this scheduler, otherwise a deadlock will occur.
    let scheduler: QueueScheduler
    
    init() {
        let queue = dispatch_queue_create("queueueueue", DISPATCH_QUEUE_SERIAL)
        scheduler = QueueScheduler(queue: queue)
    }
}
