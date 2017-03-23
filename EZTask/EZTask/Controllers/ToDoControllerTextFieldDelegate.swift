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
    
    // MARK: Delegate
    
    weak var delegate: ToDoController?
    
    // MARK: Variables
    
    var onViewTapGesture: UITapGestureRecognizer!
    
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
        delegate?.updateTasks()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
}
