//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

extension NSError {
    static func app() -> NSError {
        return NSError(domain: "com.twocentstudios.todostream", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occurred."])
    }
}