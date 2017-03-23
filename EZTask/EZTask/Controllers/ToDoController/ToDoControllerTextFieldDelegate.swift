//
//  ToDoControllerTextFieldDelegate.swift
//  EZTask
//
//  Created by Evgeniy on 23.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

class ToDoControllerTextFieldDelegate: NSObject, UITextFieldDelegate
{
    // MARK: - Properties
    
    // TODO: create base class ( or protocol) to inherit ToDoController as delegate
    
    /// Delegate to communicate with ToDoController
    fileprivate weak var delegate: ToDoController?
    /// Hides keyboard on screen anywhere tap
    var onViewTapGesture: UITapGestureRecognizer!
    /// TableView's Data source delegate
    weak var dataSourceDelegate: ToDoControllerTableViewDataSource!
    
    // MARK: - Initialization
    
    convenience init(_ delegate: ToDoController?)
    {
        self.init()
        
        self.delegate = delegate
    }
    
    // MARK: - UITextFieldDelegate & Logic
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        onViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        delegate?.view.addGestureRecognizer(onViewTapGesture)
    }
    
    func onViewTap()
    {
        let nPath = IndexPath(row: 0, section: 0)
        
        if let editingCell = delegate?.toDoTableView.cellForRow(at: nPath) as? ToDoCell
        {
            editingCell.toDoTextField.resignFirstResponder()
        }
        
        delegate?.view.removeGestureRecognizer(onViewTapGesture)
        onViewTapGesture = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.isUserInteractionEnabled = false
        
        let nPath = IndexPath(row: 0, section: 0)
        
        if let text = textField.text
        {
            if text.isEmpty || text == " "
            {
                delegate?.openTasks.removeLast()
                
                delegate?.toDoTableView.deleteRows(at: [nPath], with: .fade)
            }
            else
            {
                try! delegate?.uiRealm.write
                {
                    let lastOpenTask = delegate?.openTasks.last
                    lastOpenTask?.title = textField.text ?? ""
                }
            }
        }
        else
        {
            delegate?.openTasks.removeLast()
            delegate?.toDoTableView.deleteRows(at: [nPath], with: .fade)
        }
        
        delegate?.openTasks = (delegate?.openTasks.reversed())!
        dataSourceDelegate.updateTasks()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
}
