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

fileprivate let toDoCellIdentifier = "idToDoCell"

class ToDoController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    // MARK: - Properties
    
    let uiRealm = try! Realm()
    
    var openTasks = [ToDoTaskModel]()
    
    var completedTasks = [ToDoTaskModel]()
    
    var onViewTapGesture = UITapGestureRecognizer()
    
    fileprivate let sectionsNumber = 2
    
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        retrieveTasks()
        setupNavigationController()
        setupRefreshController()
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
    
    func setupRefreshController()
    {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = .yellow
        
        toDoTableView.dg_addPullToRefreshWithActionHandler({ [weak self]() -> Void in
            
            try! self?.uiRealm.write
            {
                let newTask = ToDoTaskModel()
                
                self?.openTasks.append(newTask)
            }
            
            let nPath = IndexPath(row: 0, section: 0)
            self?.toDoTableView.insertRows(at: [nPath], with: .fade)
            
            let newTask = self?.toDoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ToDoCell
            
            newTask.toDoTextField.text = ""
            newTask.toDoTextField.isUserInteractionEnabled = true
            newTask.toDoTextField.becomeFirstResponder()
            
            self?.toDoTableView.dg_stopLoading()
        }, loadingView: loadingView)
        
        toDoTableView.dg_setPullToRefreshFillColor(.appMainGreenColor) // bg color
        toDoTableView.dg_setPullToRefreshBackgroundColor(toDoTableView.backgroundColor!)
    }
    
    // MARK: - deinit
    
    deinit
    {
        toDoTableView.dg_removePullToRefresh()
    }
}

// MARK: - Extensions

// MARK: - UITextFieldDelegate

extension ToDoController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        onViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        view.addGestureRecognizer(onViewTapGesture)
    }
    
    func onViewTap()
    {
        let nPath = IndexPath(row: 0, section: 0)
        let editingCell = toDoTableView.cellForRow(at: nPath) as! ToDoCell
        editingCell.toDoTextField.resignFirstResponder()
        
        view.removeGestureRecognizer(onViewTapGesture)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.isUserInteractionEnabled = false
        
        let nPath = IndexPath(row: 0, section: 0)
        
        if let text = textField.text
        {
            if text.isEmpty || text == " "
            {
                openTasks.removeLast()
                
                //                try! uiRealm.write
                //                {
                //                    uiRealm.delete(uiRealm.objects(ToDoTaskModel).last!)
                //                }
                
                toDoTableView.deleteRows(at: [nPath], with: .fade)
            }
            else
            {
                try! uiRealm.write
                {
                    //                    let lastOpenTask = uiRealm.objects(ToDoTaskModel).last!
                    let lastOpenTask = openTasks.last
                    lastOpenTask?.title = textField.text ?? ""
                }
            }
        }
        else
        {
            openTasks.removeLast()
            //            try! uiRealm.write
            //            {
            //                uiRealm.delete(uiRealm.objects(ToDoTaskModel).last!)
            //            }
            toDoTableView.deleteRows(at: [nPath], with: .fade)
        }
        
        openTasks = openTasks.reversed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: UITableViewDelegate

extension ToDoController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let timer = UITableViewRowAction(style: .normal, title: "Напомнить")
        { action, index in
        }
        timer.backgroundColor = .flatYellow
        
        let del = UITableViewRowAction(style: .default, title: "Удалить")
        { action, index in
            
            let section = indexPath.section
            if section == 0
            {
                self.openTasks.remove(at: indexPath.row)
            }
            else
            {
                self.completedTasks.remove(at: indexPath.row)
            }
            
            //            try! self.uiRealm.write
            //            {
            //                let section = indexPath.section
            //
            //                if section == 0
            //                {
            //                    self.uiRealm.delete(self.openTasks[indexPath.row])
            //                }
            //                else
            //                {
            //                    self.uiRealm.delete(self.completedTasks[indexPath.row])
            //                }
            //                self.toDoTableView.deleteRows(at: [indexPath], with: .fade)
            //            }
            
        }
        del.backgroundColor = .red
        return [del, timer]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
}

extension ToDoController
{
    func configureCell(_ cell: ToDoCell, indexPath: IndexPath)
    {
        let checkView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "checkMarkIcon"))
        let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        
        let clockView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "watchesIcon"))
        let yellowColor = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
        
        if let bgView = self.toDoTableView.backgroundView
        {
            if let bgColor = bgView.backgroundColor
            {
                cell.settings.defaultColor = bgColor
            }
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0
        {
            cell.toDoTextField.text = openTasks[row].title
        }
        else
        {
            cell.toDoTextField.text = completedTasks[row].title
        }
        
        cell.toDoTextField.isUserInteractionEnabled = false
        cell.settings.secondTrigger = 0.66
        cell.settings.startImmediately = true
        cell.selectionStyle = .none
        
        // TODO: make deletion on right side & change secondTrigger to a smaller value
        
        // TODO: add gradient & animation on color changing
        
        cell.setSwipeGestureWith(checkView, color: greenColor, mode: .exit, state: .state1, completionBlock: { (cell, state, mode) -> Void in
            print("Marked task as done")
            
            if indexPath.section == 0
            {
                self.markTaskCompleted(cell)
            }
            else
            {
                self.unmarkTaskCompleted(cell)
            }
        })
        
        cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .none, state: .state3, completionBlock: { (cell, state, mode) -> Void in
            print("Snoozing task")
        })
        
    }
    
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
    }
}

extension ToDoController: UITableViewDataSource
{
    func retrieveTasks()
    {
        openTasks.removeAll()
        completedTasks.removeAll()
        
        let _openTasks = uiRealm.objects(ToDoTaskModel).filter("isCompleted = false")
        let _completedTasks = uiRealm.objects(ToDoTaskModel).filter("isCompleted = false")
        
        for openTask in _openTasks
        {
            openTasks.append(openTask)
        }
        
        for completedTask in _completedTasks
        {
            completedTasks.append(completedTask)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return openTasks.count
        }
        
        else
        {
            return completedTasks.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return sectionsNumber
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idToDoCell") as! ToDoCell
        
        configureCell(cell, indexPath: indexPath)
        
        let section = indexPath.section
        cell.backgroundColor = .white
        if section == 1
        {
            let attributeString = NSMutableAttributedString(string: completedTasks[indexPath.row].title)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
            
            cell.toDoTextField?.attributedText = attributeString
            cell.backgroundColor = .flatWhite
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell = tableView.cellForRow(at: indexPath) as! ToDoCell
        cell.toDoTextField.becomeFirstResponder()
    }
}

// MARK: Other

extension ToDoController
{
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
}
