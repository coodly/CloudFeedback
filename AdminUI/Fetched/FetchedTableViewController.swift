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
import CoreData

private typealias ConformsTo = NSFetchedResultsControllerDelegate & UITableViewDataSource & UITableViewDelegate

internal class FetchedTableViewController<Model: NSManagedObject, Cell: UITableViewCell>: UIViewController, ConformsTo {
    internal var tableView: UITableView!
    
    private var fetchedController: NSFetchedResultsController<Model>?
    
    internal var clearSelection = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerCell(forType: Cell.self)
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard fetchedController == nil else {
            return
        }
        
        fetchedController = createFetchedController()
        fetchedController?.delegate = self
        Log.debug("Have \((fetchedController?.fetchedObjects?.count ?? 0)) elements for \(String(describing: Model.self))")
        tableView.reloadData()
    }
    
    internal func createFetchedController() -> NSFetchedResultsController<Model> {
        fatalError("Override \(#function)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedController?.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let controller = fetchedController, let sections = controller.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as Cell
        let object = fetchedController!.object(at: indexPath)
        configure(cell: cell, with: object, at: indexPath)
        return cell
    }
    
    func configure(cell: Cell, with object: Model, at indexPath: IndexPath) {
        Log.debug("Configure cell at \(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = fetchedController?.object(at: indexPath) else {
            return
        }
        
        tapped(item, at: indexPath)
        
        guard clearSelection else {
            return
        }
    }
    
    func tapped(_ object: Model, at indexPath: IndexPath) {
        
    }
    
    internal func updateFetch(_ predicate: NSPredicate) {
        fetchedController?.fetchRequest.predicate = predicate
        try! fetchedController?.performFetch()
        tableView.reloadData()
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case NSFetchedResultsChangeType.update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case NSFetchedResultsChangeType.insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case NSFetchedResultsChangeType.delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case NSFetchedResultsChangeType.move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .update:
            tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move:
            fatalError("Wut? \(sectionIndex)")
        }
    }
}
