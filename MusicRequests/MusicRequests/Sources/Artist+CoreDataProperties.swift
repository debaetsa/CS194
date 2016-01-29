//
//  Artist+CoreDataProperties.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/25/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Artist {

  @NSManaged var name: String?
  @NSManaged var singles: NSSet?
  @NSManaged var albums: NSSet?
  @NSManaged var people: NSSet?

}
