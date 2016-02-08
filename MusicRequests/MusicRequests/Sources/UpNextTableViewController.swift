//
//  UpNextTableViewController.swift
//  Music Requests
//
//  Created by Matthew Volk on 1/31/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class UpNextTableViewController: ItemTableViewController {

  var listener: NSObjectProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()

    let center = NSNotificationCenter.defaultCenter()
    listener = center.addObserverForName(Queue.didChangeNowPlayingNotification, object: nil, queue: nil, usingBlock: { (note) in
      if let queue = (note.object as? Queue) {
        print("New Song: \(queue.current); Next Up Is: \(queue.upcoming.first)")
      }
    })
  }

  deinit {
    if let listener = self.listener {
      let center = NSNotificationCenter.defaultCenter()
      center.removeObserver(listener)
    }
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return library.allSongs.count
  }


  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    //let songs = library.allSongs
    
    /* Here I am just populating songs by accessing what is in the queue 
       Comment this out and uncomment above (as well as two other lines indiciated
       by comments) to return to the previous functionality*/
    var songs = queue.history
    if queue.current != nil {
      songs.append(queue.current!)
    }
    songs.appendContentsOf(queue.upcoming)

    var cell: UITableViewCell
    //replace queue.history.count with 4 to return to previous functionality
    if (indexPath.row == queue.history.count) {
      cell = tableView.dequeueReusableCellWithIdentifier("BigCell", forIndexPath: indexPath)
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
    }
    let currentSong = songs[indexPath.row].song

    cell.textLabel?.text = "\(currentSong.name)"

    var detailComponents = [String]()
    if let name = currentSong.artist?.name {
      detailComponents.append(name)
    }
    if let name = currentSong.album?.name {
      detailComponents.append(name)
    }
    cell.detailTextLabel?.text = detailComponents.joinWithSeparator(" • ")

    cell.imageView?.image = currentSong.album!.imageToShow

    return cell
  }

  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    // "4" Hardcoded for now, will replace with currently_playing song next week

    //replace queue.history.count with 4 to return to previous functionality
    if(indexPath.row != queue.history.count) {
      return 50.0
    }
    return 100.0
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let clickedOnSong = library.allSongs[indexPath.row]
    songTitle = clickedOnSong.name
    artistName = clickedOnSong.artist!.name
    albumName = clickedOnSong.album!.name
    
    performSegueWithIdentifier("ToPreview", sender: self)
  }
}
