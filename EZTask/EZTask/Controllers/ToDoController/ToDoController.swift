//
//  ViewController.swift
//  EZTask
//
//  Created by Evgeniy on 19.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit
import RealmSwift
import Chameleon

class ToDoController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    // MARK: - Properties
    
    // MARK: Delegate
    
    var textFieldDelegate: ToDoControllerTextFieldDelegate?
    
    var tableViewDelegate: ToDoControllerTableViewDelegate?
    
    var tableViewDataSource: ToDoControllerTableViewDataSource?
    
    // MARK: Realm
    
    let uiRealm = try! Realm()
    
    var savedTasks: SavedTasksModel!
    
    // TODO: make a realm class manager to keep this
    
    var openTasks = [ToDoTaskModel]()
    
    var completedTasks = [ToDoTaskModel]()
    
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupDelegates()
        tableViewDataSource?.retrieveTasks()
        setupNavigationController()
    }
    
    // MARK: - Logic setup
    
    func setupDelegates()
    {
        textFieldDelegate = ToDoControllerTextFieldDelegate(self)
        
        tableViewDataSource = ToDoControllerTableViewDataSource(self)
        
        tableViewDelegate = ToDoControllerTableViewDelegate(self, textFieldDelegate: textFieldDelegate)
        toDoTableView.delegate = tableViewDelegate
        tableViewDelegate?.setupRefreshController()
        
        textFieldDelegate?.dataSourceDelegate = tableViewDataSource
        tableViewDataSource?.toDoTableViewDelegate = tableViewDelegate
    }
    
    // MARK: - View setup
    
    func setupNavigationController()
    {
        navigationController?.navigationBar.barTintColor = .appMainGreenColor
        navigationController?.navigationBar.tintColor = .appMainGreenColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.clipsToBounds = true
        navigationItem.title = "To-Do List"
    }
}

// MARK: - Extensions

extension ToDoController
{
    func markTaskCompleted(_ cell: KZSwipeTableViewCell)
    {
        if let indexPath = toDoTableView.indexPath(for: cell)
        {
            let task = openTasks[indexPath.row]
            
            let newCompletedTask = ToDoTaskModel()
            newCompletedTask.isCompleted = true
            newCompletedTask.title = task.title
            
            openTasks.remove(at: indexPath.row)
            completedTasks.insert(newCompletedTask, at: 0)
            
            let nPath = IndexPath(row: 0, section: 1)
            
            toDoTableView.moveRow(at: indexPath, to: nPath)
            toDoTableView.reloadRows(at: [nPath], with: .fade)
            
            toDoTableView.scrollToRow(at: nPath, at: .top, animated: true)
        }
        tableViewDataSource?.updateTasks()
    }
    
    func unmarkTaskCompleted(_ cell: KZSwipeTableViewCell)
    {
        if let indexPath = toDoTableView.indexPath(for: cell)
        {
            let task = completedTasks[indexPath.row]
            
            let newUnmarkedTask = ToDoTaskModel()
            newUnmarkedTask.isCompleted = false
            newUnmarkedTask.title = task.title
            
            completedTasks.remove(at: indexPath.row)
            openTasks.insert(newUnmarkedTask, at: 0)
            
            let nPath = IndexPath(row: 0, section: 0)
            
            toDoTableView.moveRow(at: indexPath, to: nPath)
            toDoTableView.reloadRows(at: [nPath], with: .fade)
            
            toDoTableView.scrollToRow(at: nPath, at: .top, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute:
                {
                    if let cell = self.toDoTableView.cellForRow(at: IndexPath(row: 0, section: 0))
                    {
                        if let cell = cell as? ToDoCell
                        {
                            cell.toDoTextField.becomeFirstResponder()
                            cell.backgroundColor = .white
                        }
                    }
            })
        }
        tableViewDataSource?.updateTasks()
    }
}

// MARK: Other

extension ToDoController
{
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
}
