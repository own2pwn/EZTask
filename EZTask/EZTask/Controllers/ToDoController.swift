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
    
    var openTasks: Results<ToDoTaskModel>!
    
    var completedTasks: Results<ToDoTaskModel>!
    
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
                self?.uiRealm.add(ToDoTaskModel())
            }
            
            //            self?.openTasks += 1
            
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
                //                openTasks -= 1
                
                try! uiRealm.write
                {
                    uiRealm.delete(uiRealm.objects(ToDoTaskModel).last!)
                }
                
                toDoTableView.deleteRows(at: [nPath], with: .fade)
            }
        }
        else
        {
            //            openTasks -= 1
            try! uiRealm.write
            {
                uiRealm.delete(uiRealm.objects(ToDoTaskModel).last!)
            }
            toDoTableView.deleteRows(at: [nPath], with: .fade)
        }
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
            print("More")
        }
        timer.backgroundColor = .flatYellow
        
        let del = UITableViewRowAction(style: .default, title: "Удалить")
        { action, index in
            print("delete")
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
        
        _ = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "sticksIconIcon"))
        _ = UIColor(red: 206.0 / 255.0, green: 149.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        
        if let bgView = self.toDoTableView.backgroundView
        {
            if let bgColor = bgView.backgroundColor
            {
                cell.settings.defaultColor = bgColor
            }
        }
        
        cell.toDoTextField.text = "mem"
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
            
            try! uiRealm.write
            {
                task.isCompleted = true
            }
            
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
            try! uiRealm.write
            {
                task.isCompleted = false
            }
            
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
        openTasks = uiRealm.objects(ToDoTaskModel).filter("isCompleted = false")
        completedTasks = uiRealm.objects(ToDoTaskModel).filter("isCompleted = true")
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
            let attributeString = NSMutableAttributedString(string: (cell.toDoTextField?.text)!)
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
