//
//  Stock+CoreDataProperties.swift
//  Portfolio
//
//  Created by Daniel on 2/25/16.
//  Copyright © 2016 Daniel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stock {

    @NSManaged var exchange: String?
    @NSManaged var name: String?
    @NSManaged var numShare: NSNumber?
    @NSManaged var price: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var symbol: String?

}
