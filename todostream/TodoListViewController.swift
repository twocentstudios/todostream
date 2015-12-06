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

        /// .ResTodos
        appContext.eventsSignal
            .map { event -> Result<[TodoViewModel], NSError>? in
                switch event {
                case .ResponseTodoViewModels(let result): return result
                default: return nil
                }
            }
            .ignoreNil()
            .map { $0.value }
            .ignoreNil()
            .observeOn(UIScheduler())
            .observeNext { [unowned self] todoViewModels in
                if (self.viewModels == todoViewModels) { return }
                self.viewModels = todoViewModels
                self.tableView.reloadData()
            }
        
        appContext.eventsSignal
            .map { event -> Result<TodoViewModel, NSError>? in
                switch event {
                case .ResponseTodoViewModel(let result): return result
                default: return nil
                }
            }
            .ignoreNil()
            .map { $0.value }
            .ignoreNil()
            .observeOn(UIScheduler())
            .observeNext { [unowned self] todoViewModel in
                if let index = self.viewModels.indexOf(todoViewModel) {
                    // TODO: delete
                    // replace
                    self.viewModels[index] = todoViewModel
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Left)
                } else {
                    self.viewModels.insert(todoViewModel, atIndex: 0)
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
                }
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appContext.eventsObserver.sendNext(Event.RequestTodoViewModels)
    }
    
    func doAdd() {
        appContext.eventsObserver.sendNext(Event.RequestAddRandomTodoViewModel)
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
        let vm = viewModels[indexPath.row]
        print(vm)
        // TODO: present
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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