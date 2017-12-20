/*
 * Copyright 2017 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import CloudKit
import CloudFeedback

public class CoreInjection {
    public static let sharedInstance = CoreInjection()
    
    private lazy var persistence = Persistence()
    private lazy var feedbackConainer = CKContainer(identifier: "iCloud.com.coodly.feedback")
    private lazy var feedback = Feedback(container: self.feedbackConainer)
    private lazy var adminModule = self.feedback.admin
    private lazy var feedbackManager: FeedbackManager = {
        let manager = FeedbackManager()
        self.inject(into: manager)
        return manager
    }()
    
    public func inject(into object: AnyObject) {
        if var consumer = object as? PersistenceConsumer {
            consumer.persistence = persistence
        }
        
        if var consumer = object as? FeedbackAdminConsumer {
            consumer.adminModule = adminModule
        }
        
        if var consumer = object as? FeedbackManagerConsumer {
            consumer.manager = feedbackManager
        }
    }
}
