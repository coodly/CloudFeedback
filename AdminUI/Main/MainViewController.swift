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

public class MainViewController: UIViewController, StoryboardLoaded, UIInjector {
    public static var storyboardName: String {
        return "Main"
    }
    
    @IBOutlet private var applicationsContainer: UIView!
    @IBOutlet private var conversationsContainer: UIView!
    @IBOutlet private var messagesContainer: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let applications = Storyboards.loadFromStoryboard() as ApplicationsViewController
        inject(into: applications)
        let aoplicationsNavigation = UINavigationController(rootViewController: applications)
        addChildViewController(aoplicationsNavigation)
        applicationsContainer.addSubview(aoplicationsNavigation.view)
        aoplicationsNavigation.view.pinToSuperviewEdges()
        
        let conversations = Storyboards.loadFromStoryboard() as ConversationsViewController
        inject(into: conversations)
        let conversationsNavigation = UINavigationController(rootViewController: conversations)
        addChildViewController(conversationsNavigation)
        conversationsContainer.addSubview(conversationsNavigation.view)
        conversationsNavigation.view.pinToSuperviewEdges()
        
        let messages = Storyboards.loadFromStoryboard() as MessagesViewController
        inject(into: messages)
        let messagesNavigation = UINavigationController(rootViewController: messages)
        addChildViewController(messagesNavigation)
        messagesContainer.addSubview(messagesNavigation.view)
        messagesNavigation.view.pinToSuperviewEdges()
    }
}
