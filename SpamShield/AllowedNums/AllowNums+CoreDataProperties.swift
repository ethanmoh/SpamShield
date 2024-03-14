//
//  AllowNums+CoreDataProperties.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/17/23.
//
//

import Foundation
import CoreData


extension AllowNums {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllowNums> {
        return NSFetchRequest<AllowNums>(entityName: "AllowNums")
    }

    @NSManaged public var number: String?

}

extension AllowNums : Identifiable {

}
