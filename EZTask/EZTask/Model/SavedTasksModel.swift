//
//  SavedTasksModel.swift
//  EZTask
//
//  Created by Evgeniy on 23.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit
import RealmSwift

class SavedTasksModel: Object
{
    dynamic var id = 0

    var openTasks = List<ToDoTaskModel>()
    var completedTasks = List<ToDoTaskModel>()

    override class func primaryKey() -> String?
    {
        return "id"
    }
}
