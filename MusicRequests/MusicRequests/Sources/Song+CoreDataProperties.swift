//
//  Song+CoreDataProperties.swift
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

extension Song {

    @NSManaged var name: String?
    @NSManaged var artists: NSSet?
    @NSManaged var genres: NSSet?
    @NSManaged var tracks: NSSet?

}
