//
//  SongsTableViewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class SongsTableViewController: ItemTableViewController {

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return library.allSongs.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)

    let songs = library.allSongs
    let currentSong = songs[indexPath.row]

    cell.textLabel?.text = "\(currentSong.cachedVote) \(currentSong.name)"
    cell.detailTextLabel?.text = currentSong.artistAlbumString
    cell.imageView?.image = currentSong.album!.imageToShow

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let remoteQueue = AppDelegate.sharedDelegate.currentSession.queue as? RemoteQueue {
      remoteQueue.upvote(withSong: library.allSongs[indexPath.row])
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == "preview" {
      let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
      let destination = segue.destinationViewController as! SongViewController
      destination.song = library.allSongs[indexPath.row]
    }
  }
  
  override func tableView(tableView: UITableView,
    editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let upvote = UITableViewRowAction(style: .Normal, title: "+") { action, index in
      let currentSong = self.library.allSongs[indexPath.row];
      currentSong.votes! += 1;
      self.queue.refreshUpcoming()
      print("Upvoted song: \(currentSong.name): \(currentSong.votes!)");
    }
    upvote.backgroundColor = UIColor.blueColor()
    
    let downvote = UITableViewRowAction(style: .Normal, title: "-") { action, index in
      let currentSong = self.library.allSongs[indexPath.row];
      currentSong.votes! -= 1;
      self.queue.refreshUpcoming()
      print("Upvoted song: \(currentSong.name): \(currentSong.votes!)");
    }
    downvote.backgroundColor = UIColor.redColor()
    
    return [downvote, upvote]
  }

}
