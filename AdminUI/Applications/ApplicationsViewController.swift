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

private typealias Dependencies = PersistenceConsumer

internal class ApplicationsViewController: FetchedTableViewController<Application, ApplicationCell>, StoryboardLoaded, Dependencies {
    static var storyboardName: String {
        return "Applications"
    }
    
    var persistence: Persistence!
    
    @IBOutlet private var table: UITableView! {
        didSet {
            tableView = table
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
    }
    
    override func createFetchedController() -> NSFetchedResultsController<Application> {
        return persistence.mainContext.fetchedControllerForAllApplications()
    }
    
    override func configure(cell: ApplicationCell, with application: Application, at indexPath: IndexPath) {
        cell.textLabel?.text = application.identifier
    }
}
