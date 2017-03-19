//
//  ViewController.swift
//  EZTask
//
//  Created by Evgeniy on 19.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

class ToDoController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    // MARK: - Properties
    
    fileprivate let toDoCellIdentifier = "idToDoCell"
    
    var openTasks = 7
    
    var completedTasks = 2
    
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
}

// MARK: - Extensions

// MARK: UITableViewDelegate

extension ToDoController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let more = UITableViewRowAction(style: .normal, title: "More")
        { action, index in
            print("More")
        }
        more.backgroundColor = .lightGray
        
        let favorite = UITableViewRowAction(style: .normal, title: "Change list")
        { action, index in
            print("Change list")
        }
        favorite.backgroundColor = .orange
        
        let share = UITableViewRowAction(style: .normal, title: "Snooze")
        { action, index in
            print("Snooze")
        }
        share.backgroundColor = .blue
        
        return [share, favorite, more]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
}

extension ToDoController
{
    func configureCell(_ cell: KZSwipeTableViewCell, indexPath: IndexPath)
    {
        let checkView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "checkMarkIcon"))
        let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        
        let crossView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "crossIcon"))
        let redColor = UIColor(red: 232.0 / 255.0, green: 61.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)
        
        let clockView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "watchesIcon"))
        let yellowColor = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
        
        let listView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "sticksIconIcon"))
        let brownColor = UIColor(red: 206.0 / 255.0, green: 149.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)
        
        if let bgView = self.toDoTableView.backgroundView
        {
            if let bgColor = bgView.backgroundColor
            {
                cell.settings.defaultColor = bgColor
            }
        }
        
        cell.textLabel?.text = "Task"
        cell.detailTextLabel?.text = "Subtitle"
        cell.settings.secondTrigger = 0.66
        
        // TODO: make deletion on right side & change secondTrigger to a smaller value
        
        // TODO: add gradient & animation on color changing
        
        cell.setSwipeGestureWith(checkView, color: greenColor, mode: .exit, state: .state1, completionBlock: { (cell, state, mode) -> Void in
            print("Marked task as done")
            
            self.deleteCell(cell)
        })
        
        cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .switch, state: .state3, completionBlock: { (cell, state, mode) -> Void in
            print("Snoozing task")
        })
        
        cell.setSwipeGestureWith(listView, color: brownColor, mode: .switch, state: .state4, completionBlock: { (cell, state, mode) -> Void in
            print("Changing list of task")
        })
        
    }
    
    func deleteCell(_ cell: KZSwipeTableViewCell)
    {
        openTasks -= 1
        if let indexPath = toDoTableView.indexPath(for: cell)
        {
            toDoTableView.deleteRows(at: [indexPath], with: .fade)
            let nPath = IndexPath(row: completedTasks + 1, section: 1)
            completedTasks += 1
            toDoTableView.insertRows(at: [nPath], with: .fade)
        }
    }
}

extension ToDoController: UITableViewDataSource
{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: change
        
        if section == 0
        {
            return openTasks
        }
        
        return completedTasks
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = KZSwipeTableViewCell(style: .subtitle, reuseIdentifier: toDoCellIdentifier)
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: Other

extension ToDoController
{
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
}
