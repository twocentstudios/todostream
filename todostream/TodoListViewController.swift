//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

final class TodoListViewController: UITableViewController {
    
    let appContext: AppContext
    
    var viewModel: TodoListViewModel
    
    init(viewModel: TodoListViewModel, appContext: AppContext) {
        self.viewModel = viewModel
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
            .takeUntilNil { [weak self] in self }
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
                let change = self.viewModel.incorporateTodoViewModels(todoViewModels)
                switch change {
                case .Reload:
                    self.tableView.reloadData()
                case .NoOp:
                    break
                }
            }
        
        /// .ResponseTodoViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Result<TodoViewModel, NSError>? in if case let .ResponseTodoViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .promoteErrors(NSError)
            .attemptMap { $0 }
            .observeOn(UIScheduler())
            .flatMapError { [unowned self] error -> SignalProducer<TodoViewModel, NoError> in
                self.presentError(error) // TODO: maybe embed error in Todo/TodoViewModel instead?
                return .empty
            }
            .observeNext { [unowned self] todoViewModel in
                let change = self.viewModel.incorporateTodoViewModel(todoViewModel)
                switch change {
                case let .Insert(indexPath):
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                case let .Delete(indexPath):
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                case let .Reload(indexPath):
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                case .NoOp:
                    break
                }
            }
        
        /// .ResponseDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
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
                let navigationController = UINavigationController(rootViewController: viewController)
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        
        /// .ResponseUpdateDetailViewModel
        appContext.eventsSignal
            .takeUntilNil { [weak self] in self }
            .map { event -> Result<TodoDetailViewModel, NSError>? in if case let .ResponseUpdateDetailViewModel(result) = event { return result }; return nil }
            .ignoreNil()
            .map { $0.value }
            .ignoreNil()
            .observeOn(UIScheduler())
            .observeNext { [unowned self] detailViewModel in
                guard let navigationController = self.presentedViewController as? UINavigationController else { return }
                guard let todoDetailViewController = navigationController.topViewController as? TodoDetailViewController else { return }
                if (todoDetailViewController.viewModel != detailViewModel) { return }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appContext.eventsObserver.sendNext(Event.RequestTodoViewModels)
    }
    
    func doAdd() {
        appContext.eventsObserver.sendNext(Event.RequestNewTodoDetailViewModel)
    }
    
    func presentError(error: NSError) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TodoCell.reuseIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! TodoCell
        cell.viewModel = viewModel.viewModelAtIndexPath(indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todoViewModel = viewModel.viewModelAtIndexPath(indexPath)
        appContext.eventsObserver.sendNext(Event.RequestTodoDetailViewModel(todoViewModel))
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let todoViewModel = viewModel.viewModelAtIndexPath(indexPath)
        
        let toggleCompleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: todoViewModel.completeActionTitle) { [unowned self] (action, path) -> Void in
            let todoViewModel = self.viewModel.viewModelAtIndexPath(path)
            self.appContext.eventsObserver.sendNext(Event.RequestToggleCompleteTodoViewModel(todoViewModel))
        }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { [unowned self] (action, path) -> Void in
            let todoViewModel = self.viewModel.viewModelAtIndexPath(path)
            self.appContext.eventsObserver.sendNext(Event.RequestDeleteTodoViewModel(todoViewModel))
        }
        
        return [deleteAction, toggleCompleteAction]
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