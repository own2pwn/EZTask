//
//  ToDoControllerTableViewDataSource.swift
//  EZTask
//
//  Created by Evgeniy on 23.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

fileprivate let toDoCellIdentifier = "idToDoCell"
fileprivate let sectionsNumber = 2

class ToDoControllerTableViewDataSource: NSObject, UITableViewDataSource
{
    // MARK: - Properties
    
    /// Delegate to communicate with ToDoController
    weak var delegate: ToDoController?
    /// Delegate to communicate with ToDoTableView
    weak var toDoTableViewDelegate: ToDoControllerTableViewDelegate?
    
    // MARK: - Initialization
    
    convenience init(_ delegate: ToDoController?)
    {
        self.init()
        
        self.delegate = delegate
    }
    
    // MARK: - Methods
    
    func retrieveTasks()
    {
        if let availableTasks = delegate?.uiRealm.objects(SavedTasksModel.self).first
        {
            let _openTasks = availableTasks.openTasks
            let _completedTasks = availableTasks.completedTasks
            
            for oTask in _openTasks
            {
                delegate?.openTasks.append(oTask)
            }
            
            for cTask in _completedTasks
            {
                delegate?.completedTasks.append(cTask)
            }
        }
    }
    
    func updateTasks()
    {
        let _savedTasks = SavedTasksModel()
        _savedTasks.id = 0
        
        try! delegate?.uiRealm.write
        {
            _savedTasks.openTasks.removeAll()
            _savedTasks.completedTasks.removeAll()
        }
        
        for openTask in (delegate?.openTasks)!
        {
            _savedTasks.openTasks.append(openTask)
        }
        
        for completedTask in (delegate?.completedTasks)!
        {
            _savedTasks.completedTasks.append(completedTask)
        }
        
        try! delegate?.uiRealm.write
        {
            delegate?.uiRealm.add(_savedTasks, update: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return (delegate?.openTasks.count)!
        }
        
        else
        {
            return (delegate?.completedTasks.count)!
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return sectionsNumber
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: toDoCellIdentifier) as! ToDoCell
        
        toDoTableViewDelegate?.configureCell(cell, indexPath: indexPath)
        
        let section = indexPath.section
        cell.backgroundColor = .white
        if section == 1
        {
            let attributeString = NSMutableAttributedString(string: (delegate?.completedTasks[indexPath.row].title)!)
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
