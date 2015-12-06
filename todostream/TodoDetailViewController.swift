//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

final class TodoDetailViewController: UITableViewController {
    
    let appContext: AppContext
    
    var viewModel: TodoDetailViewModel
    
    init(viewModel: TodoDetailViewModel, appContext: AppContext) {
        self.viewModel = viewModel
        self.appContext = appContext
        super.init(style: .Grouped)
        
        self.title = "Update Item"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "doCancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "doSave")
        
        tableView.registerClass(TodoDetailCell.self, forCellReuseIdentifier: TodoDetailCell.reuseIdentifier)
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        
        appContext.eventsSignal
            .map { event -> Result<TodoDetailViewModel, NSError>? in if case let .ResponseUpdateDetailViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .map { $0.error }
            .ignoreNil()
            .observeOn(UIScheduler())
            .observeNext { [unowned self] error in
                self.presentError(error)
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func doCancel() {
        appContext.eventsObserver.sendNext(Event.ResponseUpdateDetailViewModel(Result(value: viewModel)))
    }
    
    func doSave() {
        appContext.eventsObserver.sendNext(Event.RequestUpdateDetailViewModel(viewModel))
    }
    
    func presentError(error: NSError) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.propertyCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TodoDetailCell.reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Title"
        case 1: return "Subtitle"
        case 2: return "Priority"
        case 3: return nil
        case 4: return nil
        default: return nil
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = nil
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.textColor = cell.tintColor
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = viewModel.title
            cell.detailTextLabel?.text = "edit"
        case 1:
            cell.textLabel?.text = viewModel.subtitle
            cell.detailTextLabel?.text = "edit"
        case 2:
            cell.textLabel?.text = viewModel.priorityString
            cell.detailTextLabel?.text = "toggle"
        case 3:
            cell.textLabel?.text = viewModel.completedString
            cell.detailTextLabel?.text = "toggle"
        case 4:
            cell.textLabel?.text = viewModel.deletedString
            cell.textLabel?.textColor = UIColor.redColor()
            cell.detailTextLabel?.text = "toggle"
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let alertController = UIAlertController(title: "Update title", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler { $0.text = self.viewModel.title }
            alertController.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.Default) { _ in
                if let newText = alertController.textFields?.first?.text { self.viewModel.title = newText }
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        case 1:
            let alertController = UIAlertController(title: "Update subtitle", message: nil, preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler { $0.text = self.viewModel.subtitle }
            alertController.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.Default) { _ in
                if let newText = alertController.textFields?.first?.text { self.viewModel.subtitle = newText }
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        case 2:
            viewModel.togglePriority()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case 3:
            viewModel.toggleCompleted()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        case 4:
            viewModel.toggleDeleted()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default: break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

final class TodoDetailCell: UITableViewCell {
    static let reuseIdentifier = "TodoDetailCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}