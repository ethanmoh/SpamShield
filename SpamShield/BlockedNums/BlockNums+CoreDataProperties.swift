//
//  BlockNums+CoreDataProperties.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/17/23.
//
//

import Foundation
import CoreData


extension BlockNums {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlockNums> {
        return NSFetchRequest<BlockNums>(entityName: "BlockNums")
    }

    @NSManaged public var number: String?

}

extension BlockNums : Identifiable {

}
