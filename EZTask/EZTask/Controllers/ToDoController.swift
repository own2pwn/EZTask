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

    var numOfItems = 7

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
        let checkView = KZSwipeTableViewCell.viewWithImageName("checkMarkIcon")
        let greenColor = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)

        let crossView = KZSwipeTableViewCell.viewWithImageName("cross")
        let redColor = UIColor(red: 232.0 / 255.0, green: 61.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)

        let clockView = KZSwipeTableViewCell.viewWithImageName("clock")
        let yellowColor = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)

        let listView = KZSwipeTableViewCell.viewWithImageName("list")
        let brownColor = UIColor(red: 206.0 / 255.0, green: 149.0 / 255.0, blue: 98.0 / 255.0, alpha: 1.0)

        if let bgView = self.toDoTableView.backgroundView
        {
            if let bgColor = bgView.backgroundColor
            {
                cell.settings.defaultColor = bgColor
            }
        }

        if indexPath.row != (numOfItems - 1)
        {
            cell.textLabel?.text = "Task"
            cell.detailTextLabel?.text = "Subtitle"
            cell.settings.secondTrigger = 0.66

            // TODO: make deletion on right side & change secondTrigger to a smaller value

            // TODO: add gradient & animation on color changing

            cell.setSwipeGestureWith(checkView, color: greenColor, mode: .switch, state: .state1, completionBlock: { (cell, state, mode) -> Void in
                print("Marked task as done")
            })

            cell.setSwipeGestureWith(crossView, color: redColor, mode: .switch, state: .state2, completionBlock: { (cell, state, mode) -> Void in
                print("Deleting task")
            })

            cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .switch, state: .state3, completionBlock: { (cell, state, mode) -> Void in
                print("Snoozing task")
            })

            cell.setSwipeGestureWith(listView, color: brownColor, mode: .switch, state: .state4, completionBlock: { (cell, state, mode) -> Void in
                print("Changing list of task")
            })
        }
        else
        {
            cell.textLabel?.text = "Task"
            cell.detailTextLabel?.text = "Subtitle"

            cell.setSwipeGestureWith(checkView, color: greenColor, mode: .switch, state: .state1, completionBlock: { (cell, state, mode) -> Void in
                print("Marked task as done")
            })

            cell.setSwipeGestureWith(crossView, color: redColor, mode: .switch, state: .state2, completionBlock: { (cell, state, mode) -> Void in
                print("Deleting task")
            })

            cell.setSwipeGestureWith(clockView, color: yellowColor, mode: .none, state: .state3)
        }
    }

    func deleteCell(cell: KZSwipeTableViewCell)
    {
        numOfItems -= 1
        if let indexPath = self.toDoTableView.indexPath(for: cell)
        {
            toDoTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ToDoController: UITableViewDataSource
{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: change

        return 7
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
