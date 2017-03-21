//
//  ToDoTaskModel.swift
//  EZTask
//
//  Created by Evgeniy on 21.03.17.
//  Copyright © 2017 Evgeniy. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoTaskModel: Object
{
    dynamic var title = ""
    dynamic var isCompleted = false
}
