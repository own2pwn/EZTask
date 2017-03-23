//
//  ToDoControllerTextFieldDelegate.swift
//  EZTask
//
//  Created by Evgeniy on 23.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

class ToDoControllerTextFieldDelegate: UITextFieldDelegate
{
    public func `self`() -> Self {
        <#code#>
    }

    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        print("didbegin")
        
        //        onViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        //        view.addGestureRecognizer(onViewTapGesture)
    }
    
    func onViewTap()
    {
        //        let nPath = IndexPath(row: 0, section: 0)
        //        let editingCell = toDoTableView.cellForRow(at: nPath) as! ToDoCell
        //        editingCell.toDoTextField.resignFirstResponder()
        //
        //        view.removeGestureRecognizer(onViewTapGesture)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        //        textField.isUserInteractionEnabled = false
        //
        //        let nPath = IndexPath(row: 0, section: 0)
        //
        //        if let text = textField.text
        //        {
        //            if text.isEmpty || text == " "
        //            {
        //                openTasks.removeLast()
        //
        //                toDoTableView.deleteRows(at: [nPath], with: .fade)
        //            }
        //            else
        //            {
        //                try! uiRealm.write
        //                    {
        //                        let lastOpenTask = openTasks.last
        //                        lastOpenTask?.title = textField.text ?? ""
        //                }
        //            }
        //        }
        //        else
        //        {
        //            openTasks.removeLast()
        //            toDoTableView.deleteRows(at: [nPath], with: .fade)
        //        }
        //
        //        openTasks = openTasks.reversed()
        //        updateTasks()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
}
