//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct AppContext {
    let (eventsSignal, eventsObserver) = Signal<Event, NoError>.pipe()
    
    init() {
        
    }
}
