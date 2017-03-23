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
    
    // MARK: Delegate
    
    weak var delegate: ToDoController?
    
    weak var textFieldDelegate: ToDoControllerTextFieldDelegate!
    
    // MARK: - Initialization
    
    convenience init(_ delegate: ToDoController?, textFieldDelegate: ToDoControllerTextFieldDelegate!)
    {
        self.init()
        
        self.delegate = delegate
        self.textFieldDelegate = textFieldDelegate
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
                self?.delegate?.openTasks.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        del.backgroundColor = .red
        
        return [del, timer]
    }
    
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
}
