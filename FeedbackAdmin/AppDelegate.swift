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

import UIKit
import AdminCore
import AdminUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FeedbackManagerConsumer {
    var manager: FeedbackManager!
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CoreLog.enableLogging()
        
        let controller = window!.rootViewController as! InitializationViewController
        
        CoreInjection.sharedInstance.inject(into: controller)
        controller.afterLoad = {
            CoreInjection.sharedInstance.inject(into: self)
            
            let main = Storyboards.loadFromStoryboard() as MainViewController

            CoreInjection.sharedInstance.inject(into: main)

            let animation: (() -> ()) = {
                self.window?.rootViewController = main
            }
            UIView.transition(with: self.window!, duration: 0.3, options: [], animations: animation, completion: nil)
            
            self.manager.startSync()
        }
        
        return true
    }
}

