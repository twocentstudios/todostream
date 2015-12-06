//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

final class TodoListViewController: UITableViewController {
    
    let appContext: AppContext
    
    var viewModels = [TodoViewModel]()
    
    init(appContext: AppContext) {
        self.appContext = appContext
        super.init(style: .Plain)
        
        self.title = "Todo List"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "doAdd")
        
        tableView.registerClass(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.dataSource = self

        /// .ResponseTodoViewModels
        appContext.eventsSignal
            .map { event -> Result<[TodoViewModel], NSError>? in if case let .ResponseTodoViewModels(result) = event { return result }; return nil }
            .ignoreNil()
            .promoteErrors(NSError)
            .attemptMap { $0 }
            .observeOn(UIScheduler())
            .flatMapError { [unowned self] error -> SignalProducer<[TodoViewModel], NoError> in
                self.presentError(error)
                return .empty
            }
            .observeNext { [unowned self] todoViewModels in
                if (self.viewModels == todoViewModels) { return }
                self.viewModels = todoViewModels
                self.tableView.reloadData()
            }
        
        /// .ResponseTodoViewModel
        appContext.eventsSignal
            .map { event -> Result<TodoViewModel, NSError>? in if case let .ResponseTodoViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .promoteErrors(NSError)
            .attemptMap { $0 }
            .observeOn(UIScheduler())
            .flatMapError { [unowned self] error -> SignalProducer<TodoViewModel, NoError> in
                self.presentError(error)
                return .empty
            }
            .observeNext { [unowned self] todoViewModel in
                if let index = self.viewModels.indexOf(todoViewModel) {
                    if (todoViewModel.deleted) {
                        // delete
                        self.viewModels.removeAtIndex(index)
                        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Right)
                    } else {
                        // replace
                        self.viewModels[index] = todoViewModel
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Left)
                    }
                } else {
                    self.viewModels.insert(todoViewModel, atIndex: 0)
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                }
            }
        
        /// .ResponseDetailViewModel
        appContext.eventsSignal
            .map { event -> Result<TodoDetailViewModel, NSError>? in if case let .ResponseTodoDetailViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .promoteErrors(NSError)
            .attemptMap { $0 }
            .observeOn(UIScheduler())
            .flatMapError { [unowned self] error -> SignalProducer<TodoDetailViewModel, NoError> in
                self.presentError(error)
                return .empty
            }
            .observeNext { [unowned self] todoDetailViewModel in
                let viewController = TodoDetailViewController(viewModel: todoDetailViewModel, appContext: self.appContext)
                self.presentViewController(viewController, animated: true, completion: nil)
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appContext.eventsObserver.sendNext(Event.RequestTodoViewModels)
    }
    
    func doAdd() {
        appContext.eventsObserver.sendNext(Event.RequestNewDetailViewModel)
    }
    
    func presentError(error: NSError) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { _ in self.dismissViewControllerAnimated(true, completion: nil) })
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TodoCell.reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! TodoCell
        cell.viewModel = viewModels[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todoViewModel = viewModels[indexPath.row]
        print(todoViewModel)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle != .Delete) { return }
        
        let todoViewModel = viewModels[indexPath.row]
        appContext.eventsObserver.sendNext(Event.RequestDeleteTodoViewModel(todoViewModel))
    }
}

final class TodoCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"
    
    var viewModel: TodoViewModel? {
        didSet {
            self.textLabel?.text = viewModel?.title ?? ""
            self.detailTextLabel?.text = viewModel?.subtitle ?? ""
            
            self.accessoryType = viewModel.map { $0.complete ? .Checkmark : .None } ?? .None
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}