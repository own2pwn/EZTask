//
//  ToDoCell.swift
//  EZTask
//
//  Created by Evgeniy on 20.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit

class ToDoCell: KZSwipeTableViewCell
{
    @IBOutlet weak var toDoTextField: UITextField!
    
    var cellRowIndex = 0
    
    func cellWillAppear()
    {
        if 0 == cellRowIndex
        {
            print("🍏 cellWillAppear")
        }
    }
}
