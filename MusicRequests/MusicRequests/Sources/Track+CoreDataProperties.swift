//
//  Track+CoreDataProperties.swift
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

extension Track {

    @NSManaged var discNumber: Int16
    @NSManaged var songNumber: Int16
    @NSManaged var album: Album?
    @NSManaged var playlist: Playlist?
    @NSManaged var song: Song?

}
