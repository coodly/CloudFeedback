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
}
