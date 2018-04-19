//
//  ToDoControllerTableViewDelegate.swift
//  EZTask
//
//  Created by Evgeniy on 23.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

class ToDoControllerTableViewDelegate: NSObject, UITableViewDelegate
{
    // MARK: - Properties
    
    /// Delegate to communicate with ToDoController
    weak var delegate: ToDoController?
    /// Cell's TextField delegate
    weak var textFieldDelegate: ToDoControllerTextFieldDelegate!
    
    // TODO: should it be weak?
    weak var toDoTableView: UITableView!
    
    // MARK: - Initialization
    
    convenience init(_ delegate: ToDoController?, textFieldDelegate: ToDoControllerTextFieldDelegate!)
    {
        self.init()
        
        self.delegate = delegate
        self.textFieldDelegate = textFieldDelegate
        self.toDoTableView = delegate?.toDoTableView
        self.toDoTableView.dataSource = delegate?.tableViewDataSource
    }
    
    deinit
    {
        toDoTableView.dg_removePullToRefresh()
    }
    
    // MARK: - Methods
    
    func setupRefreshController()
    {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = .yellow
        
        toDoTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            
            try! self?.delegate?.uiRealm.write
            {
                let newTask = ToDoTaskModel()
                
                self?.delegate?.openTasks.append(newTask)
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
        toDoTableView.dg_setPullToRefreshBackgroundColor(delegate?.toDoTableView.backgroundColor ?? .white)
    }
    
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
            cell.toDoTextField.text = delegate?.openTasks[row].title
        }
        else
        {
            cell.toDoTextField.text = delegate?.completedTasks[row].title
        }
        
        cell.toDoTextField.isUserInteractionEnabled = false
        cell.settings.secondTrigger = 0.66
        cell.settings.startImmediately = true
        cell.selectionStyle = .none
        
        // TODO: make deletion on right side & change secondTrigger to a smaller value
        
        // TODO: add gradient & animation on color changing
        
        cell.setSwipeGestureWith(checkView, color: greenColor, mode: .exit, state: .state1, completionBlock: { [weak self] (cell, _, _) -> Void in
            log.debug("Marked task as done")
            
            if section == 0
            {
                self?.delegate?.markTaskCompleted(cell)
            }
            else
            {
                self?.delegate?.unmarkTaskCompleted(cell)
            }
        })
        
        cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .none, state: .state3, completionBlock: { (_, _, _) -> Void in
            log.debug("Snoozing task")
        })
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let cell = cell as? ToDoCell
        {
            cell.toDoTextField.delegate = textFieldDelegate
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let timer = UITableViewRowAction(style: .normal, title: "Напомнить")
        { _, _ in
        }
        timer.backgroundColor = .flatYellow
        
        let del = UITableViewRowAction(style: .destructive, title: "Удалить")
        { [weak self] _, _ in
            
            (indexPath.section == 0) ? self?.delegate?.openTasks.remove(at: indexPath.row) : self?.delegate?.completedTasks.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        del.backgroundColor = .red
        
        return [del, timer]
    }
}
