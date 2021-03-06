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

internal protocol ConversationSelectionDelegate: class {
    func selected(conversation: AdminConversation)
}

private typealias Dependencies = PersistenceConsumer

internal class ConversationsViewController: FetchedTableViewController<AdminConversation, ConversationCell>, StoryboardLoaded, Dependencies {
    static var storyboardName: String {
        return "Conversations"
    }
    
    @IBOutlet private var table: UITableView! {
        didSet {
            tableView = table
        }
    }
    
    var persistence: Persistence!
    internal weak var delegate: ConversationSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Conversations"
    }
    
    override func createFetchedController() -> NSFetchedResultsController<AdminConversation> {
        return persistence.mainContext.emptyConversationsController()
    }
    
    internal func presentConversations(for application: Application) {
        let predicate = persistence.mainContext.conversationsPredicate(for: application)
        updateFetch(predicate)
    }
    
    override func configure(cell: ConversationCell, with conversation: AdminConversation, at indexPath: IndexPath) {
        cell.conversation = conversation
    }
    
    override func tapped(_ conversation: AdminConversation, at indexPath: IndexPath) {
        delegate?.selected(conversation: conversation)
    }
}
