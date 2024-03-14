//
//  BlockKeywords+CoreDataProperties.swift
//  
//
//  Created by Ethan Mohammed on 4/17/23.
//
//

import Foundation
import CoreData


extension BlockKeywords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlockKeywords> {
        return NSFetchRequest<BlockKeywords>(entityName: "BlockKeywords")
    }

    @NSManaged public var keyword: String?

}
