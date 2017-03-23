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
    
    // MARK: - Initialization
    
    convenience init(_ delegate: ToDoController?, textFieldDelegate: ToDoControllerTextFieldDelegate!)
    {
        self.init()
        
        self.delegate = delegate
        self.textFieldDelegate = textFieldDelegate
    }
    
    // MARK: - Methods
    
    func setupRefreshController()
    {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = .yellow
        
        delegate?.toDoTableView.dg_addPullToRefreshWithActionHandler({ [weak self]() -> Void in
            
            try! self?.delegate?.uiRealm.write
            {
                let newTask = ToDoTaskModel()
                
                self?.delegate?.openTasks.append(newTask)
            }
            
            let nPath = IndexPath(row: 0, section: 0)
            self?.delegate?.toDoTableView.insertRows(at: [nPath], with: .fade)
            
            let newTask = self?.delegate?.toDoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ToDoCell
            
            newTask.toDoTextField.text = ""
            newTask.toDoTextField.isUserInteractionEnabled = true
            newTask.toDoTextField.becomeFirstResponder()
            
            self?.delegate?.toDoTableView.dg_stopLoading()
        }, loadingView: loadingView)
        
        delegate?.toDoTableView.dg_setPullToRefreshFillColor(.appMainGreenColor) // bg color
        delegate?.toDoTableView.dg_setPullToRefreshBackgroundColor(delegate?.toDoTableView.backgroundColor ?? .white)
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
        { action, index in
        }
        timer.backgroundColor = .flatYellow
        
        let del = UITableViewRowAction(style: .destructive, title: "Удалить")
        { [weak self] action, index in
            
            let section = indexPath.section
            
            if section == 0
            {
                self?.delegate?.openTasks.remove(at: indexPath.row)
            }
            else
            {
                self?.delegate?.completedTasks.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        del.backgroundColor = .red
        
        return [del, timer]
    }
}
