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
    
    private lazy var activityIndicatorItem: UIBarButtonItem = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.startAnimating()
        return UIBarButtonItem(customView: indicator)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        table.separatorStyle = .none
        
        addChildViewController(sendViewController)
        inputPlaceholder.addSubview(sendViewController.view)
        sendViewController.view.pinToSuperviewEdges()
        
        inputPlaceholder.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: .willChange, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: .willChange, name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: .willDisappear, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func createFetchedController() -> NSFetchedResultsController<Message> {
        return persistence.mainContext.emptyMessagesController()
    }
    
    func presentMessages(in conversation: Conversation) {
        let predicate = persistence.mainContext.messagesPredicate(for: conversation)
        updateFetch(predicate)
        
        navigationItem.leftBarButtonItem = activityIndicatorItem
        manager.checkMessages(for: conversation) {
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem = nil
            }
        }
        
        inputPlaceholder.isHidden = false
    }
    
    override func configure(cell: MessageCell, with message: Message, at indexPath: IndexPath) {
        cell.message = message
    }
    
    @objc fileprivate func keyboardWillChange(notification: Notification) {
        guard let info = notification.userInfo, let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        let converted = view.convert(keyboardSize, from: UIApplication.shared.keyWindow!)
        let covering = view.frame.height - converted.origin.y
        
        bottomContentConstraint.constant = covering // keyboardSize.height
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(notification: Notification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber ?? NSNumber(value: 0.3)
        
        bottomContentConstraint.constant = 0
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}

