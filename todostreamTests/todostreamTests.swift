//
//  todostreamTests.swift
//  todostreamTests
//
//  Created by Christopher Trott on 12/5/15.
//  Copyright © 2015 twocentstudios. All rights reserved.
//

import XCTest
@testable import todostream
import Result
import ReactiveCocoa
import RealmSwift

class todostreamTests: XCTestCase {
    
    var appContext: AppContext!
    var viewModelServer: ViewModelServer!
    var modelServer: ModelServer!
    
    override func setUp() {
        super.setUp()
        appContext = AppContext()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestNewTodoDetailViewModel() {
        viewModelServer = ViewModelServer(appContext: appContext)
        let event = Event.RequestNewTodoDetailViewModel
        
        let expectation = expectationWithDescription("")
        appContext.eventsSignal.observeNext { (e: todostream.Event) in
            if case let todostream.Event.ResponseTodoDetailViewModel(result) = e {
                XCTAssert(result.value != nil)
                expectation.fulfill()
            }
        }
        
        appContext.eventsObserver.sendNext(event)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testRequestToggleCompleteTodoViewModel() {
        viewModelServer = ViewModelServer(appContext: appContext)
        let todo = Todo()
        XCTAssert(todo.complete == false)
        let todoViewModel = TodoViewModel(todo: todo)
        let event = Event.RequestToggleCompleteTodoViewModel(todoViewModel)
        
        let expectation = expectationWithDescription("")
        appContext.eventsSignal.observeNext { (e: todostream.Event) in
            if case let todostream.Event.RequestWriteTodo(model) = e {
                XCTAssert(model.complete == true)
                expectation.fulfill()
            }
        }
        
        appContext.eventsObserver.sendNext(event)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testIntegrationRequestToggleCompleteTodoViewModel() {
        viewModelServer = ViewModelServer(appContext: appContext)
        modelServer = ModelServer(configuration: Realm.Configuration.defaultConfiguration, appContext: appContext)
        let todo = Todo()
        XCTAssert(todo.complete == false)
        let todoViewModel = TodoViewModel(todo: todo)
        let event = Event.RequestToggleCompleteTodoViewModel(todoViewModel)
        
        let expectation = expectationWithDescription("")
        appContext.eventsSignal.observeNext { (e: todostream.Event) in
            if case let todostream.Event.ResponseTodoViewModel(result) = e {
                let model = result.value!.todo
                XCTAssert(model.id == todo.id)
                XCTAssert(model.complete == true)
                expectation.fulfill()
            }
        }
        
        appContext.eventsObserver.sendNext(event)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
