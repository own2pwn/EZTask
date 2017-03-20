//
//  ViewController.swift
//  EZTask
//
//  Created by Evgeniy on 19.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit
import Chameleon

class ToDoController: UIViewController
{
    // MARK: - Outlets
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    // MARK: - Properties
    
    fileprivate let toDoCellIdentifier = "idToDoCell"
    
    var openTasks = 25
    
    var completedTasks = 0
    
    fileprivate let sectionsNumber = 2
    
    // MARK: - Life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 170))
        headerView.backgroundColor = UIColor.red
        
        self.toDoTableView.tableHeaderView = headerView
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78 / 255.0, green: 221 / 255.0, blue: 200 / 255.0, alpha: 1.0)
        toDoTableView.dg_addPullToRefreshWithActionHandler({ [weak self]() -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.toDoTableView.dg_stopLoading()
        }, loadingView: loadingView)
        toDoTableView.dg_setPullToRefreshFillColor(UIColor(red: 57 / 255.0, green: 67 / 255.0, blue: 89 / 255.0, alpha: 1.0))
        toDoTableView.dg_setPullToRefreshBackgroundColor(toDoTableView.backgroundColor!)
    }
    
    deinit
    {
        toDoTableView.dg_removePullToRefresh()
    }
}

// MARK: - Extensions

// MARK: - Scrolling

extension ToDoController
{
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        _ = 2
    }
    
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    //    {
    //        if (velocity.y < -0.3)
    //        {
    //            if let t = self.toDoTableView.indexPathsForVisibleRows
    //            {
    //                for ip in t
    //                {
    //                    if ip.row == 0
    //                    {
    //                        print("R:\(ip.row)")
    //                    }
    //                }
    //            }
    //        }
    //    }
    
}

// MARK: UITableViewDelegate

extension ToDoController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let timer = UITableViewRowAction(style: .normal, title: "\u{231A}")
        { action, index in
            print("More")
        }
        timer.backgroundColor = .yellow
        
        let del = UITableViewRowAction(style: .default, title: "\u{274C}")
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
    func configureCell(_ cell: KZSwipeTableViewCell, indexPath: IndexPath)
    {
        let checkView = KZSwipeTableViewCell.viewWithImage(#imageLiteral(resourceName: "checkMarkIcon"))
        let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        
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
        openTasks -= 1
        if let indexPath = toDoTableView.indexPath(for: cell)
        {
            toDoTableView.deleteRows(at: [indexPath], with: .fade)
            let nPath = IndexPath(row: 0, section: 1)
            completedTasks += 1
            toDoTableView.insertRows(at: [nPath], with: .fade)
        }
    }
    
    func unmarkTaskCompleted(_ cell: KZSwipeTableViewCell)
    {
        completedTasks -= 1
        if let indexPath = toDoTableView.indexPath(for: cell)
        {
            toDoTableView.deleteRows(at: [indexPath], with: .fade)
            let nPath = IndexPath(row: 0, section: 0)
            openTasks += 1
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
        return sectionsNumber
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = KZSwipeTableViewCell(style: .subtitle, reuseIdentifier: toDoCellIdentifier)
        
        configureCell(cell, indexPath: indexPath)
        
        let section = indexPath.section
        
        if section == 1
        {
            let attributeString = NSMutableAttributedString(string: (cell.textLabel?.text)!)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
            
            cell.textLabel?.attributedText = attributeString
            cell.backgroundColor = .flatWhite
        }
        
        return cell
    }
}

// MARK: Other

extension ToDoController
{
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
}
