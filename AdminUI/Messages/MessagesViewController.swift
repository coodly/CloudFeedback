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
import CoreData

private extension Selector {
    static let willChange = #selector(MessagesViewController.keyboardWillChange(notification:))
    static let willDisappear = #selector(MessagesViewController.keyboardWillDisappear(notification:))
    static let refreshConversation = #selector(MessagesViewController.refreshConversation)
}

private typealias Dependencies = PersistenceConsumer & FeedbackManagerConsumer

internal class MessagesViewController: FetchedTableViewController<Message, MessageCell>, StoryboardLoaded, Dependencies {
    static var storyboardName: String {
        return "Messages"
    }
    
    var persistence: Persistence!
    var manager: FeedbackManager!
    
    @IBOutlet private var table: UITableView! {
        didSet {
            tableView = table
        }
    }
    @IBOutlet private var inputPlaceholder: UIView!
    @IBOutlet private var bottomContentConstraint: NSLayoutConstraint!
    private lazy var sendViewController: SendViewController = Storyboards.loadFromStoryboard()
    private lazy var refresh = UIRefreshControl()
    private var conversation: Conversation?
    
    private lazy var activityIndicatorItem: UIBarButtonItem = {
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.startAnimating()
        return UIBarButtonItem(customView: indicator)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        table.separatorStyle = .none
        
        addChild(sendViewController)
        inputPlaceholder.addSubview(sendViewController.view)
        sendViewController.view.pinToSuperviewEdges()
        
        inputPlaceholder.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: .willChange, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .willChange, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .willDisappear, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: .refreshConversation, for: .valueChanged)
    }
    
    override func createFetchedController() -> NSFetchedResultsController<Message> {
        return persistence.mainContext.emptyMessagesController()
    }
    
    func presentMessages(in conversation: Conversation) {
        self.conversation = conversation
        
        let predicate = persistence.mainContext.messagesPredicate(for: conversation)
        updateFetch(predicate)
        
        navigationItem.leftBarButtonItem = activityIndicatorItem
        manager.checkMessages(for: conversation) {
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem = nil
            }
        }
        
        inputPlaceholder.isHidden = false
        sendViewController.conversation = conversation
    }
    
    override func configure(cell: MessageCell, with message: Message, at indexPath: IndexPath) {
        cell.message = message
    }
    
    @objc fileprivate func keyboardWillChange(notification: Notification) {
        guard let info = notification.userInfo, let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        let converted = view.convert(keyboardSize, from: UIApplication.shared.keyWindow!)
        let covering = view.frame.height - converted.origin.y
        
        bottomContentConstraint.constant = covering // keyboardSize.height
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        bottomContentConstraint.constant = 0
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func refreshConversation() {
        guard let refreshed = conversation else {
            refresh.endRefreshing()
            return
        }
        
        manager.checkMessages(for: refreshed, onlyUpdates: false) {
            DispatchQueue.main.async {
                self.refresh.endRefreshing()
            }
        }
    }
}

