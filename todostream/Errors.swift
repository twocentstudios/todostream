//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import Foundation

extension NSError {
    static func app(message: String? = nil) -> NSError {
        let defaultMessage = "An error occurred."
        return NSError(domain: "com.twocentstudios.todostream", code: 0, userInfo: [NSLocalizedDescriptionKey : message ?? defaultMessage])
    }
}