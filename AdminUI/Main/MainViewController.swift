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

private extension Selector {
    static let checkConversations = #selector(MainViewController.checkConversations)
}

private typealias Dependencies = FeedbackManagerConsumer

public class MainViewController: UIViewController, StoryboardLoaded, UIInjector, Dependencies {
    public static var storyboardName: String {
        return "Main"
    }
    
    public var manager: FeedbackManager!
    
    @IBOutlet private var applicationsContainer: UIView!
    private var applicationsController: ApplicationsViewController?
    @IBOutlet private var conversationsContainer: UIView!
    private var conversationsController: ConversationsViewController?
    @IBOutlet private var messagesContainer: UIView!
    private var messagesController: MessagesViewController?
    private lazy var activityIndicatorItem: UIBarButtonItem = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.startAnimating()
        return UIBarButtonItem(customView: indicator)
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let applications = Storyboards.loadFromStoryboard() as ApplicationsViewController
        inject(into: applications)
        applicationsController = applications
        applications.delegate = self
        let aoplicationsNavigation = UINavigationController(rootViewController: applications)
        addChildViewController(aoplicationsNavigation)
        applicationsContainer.addSubview(aoplicationsNavigation.view)
        aoplicationsNavigation.view.pinToSuperviewEdges()
        
        let conversations = Storyboards.loadFromStoryboard() as ConversationsViewController
        inject(into: conversations)
        conversationsController = conversations
        conversations.delegate = self
        let conversationsNavigation = UINavigationController(rootViewController: conversations)
        addChildViewController(conversationsNavigation)
        conversationsContainer.addSubview(conversationsNavigation.view)
        conversationsNavigation.view.pinToSuperviewEdges()
        
        let messages = Storyboards.loadFromStoryboard() as MessagesViewController
        inject(into: messages)
        messagesController = messages
        let messagesNavigation = UINavigationController(rootViewController: messages)
        addChildViewController(messagesNavigation)
        messagesContainer.addSubview(messagesNavigation.view)
        messagesNavigation.view.pinToSuperviewEdges()
        
        NotificationCenter.default.addObserver(self, selector: .checkConversations, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkConversations()
    }
    
    @objc fileprivate func checkConversations() {
        Log.debug("Check conversations")
        applicationsController?.navigationItem.rightBarButtonItem = activityIndicatorItem
        manager.checkConversationUpdates() {
            DispatchQueue.main.async {
                self.applicationsController?.navigationItem.rightBarButtonItem = nil
            }
        }
    }
}

extension MainViewController: ApplicationSelectionDelegate {
    func selected(application: Application) {
        conversationsController?.presentConversations(for: application)
    }
}

extension MainViewController: ConversationSelectionDelegate {
    func selected(conversation: Conversation) {
        messagesController?.presentMessages(in: conversation)
    }
}
