//
//  AllowKeywords+CoreDataProperties.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/17/23.
//
//

import Foundation
import CoreData


extension AllowKeywords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AllowKeywords> {
        return NSFetchRequest<AllowKeywords>(entityName: "AllowKeywords")
    }

    @NSManaged public var keyword: String?

}

extension AllowKeywords : Identifiable {

}
