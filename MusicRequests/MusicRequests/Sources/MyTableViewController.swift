//
//  MyTableViewController.swift
//  appName
//
//  Created by Matthew Volk on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController {
    
    let library = TemporaryLibrary()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return library.allSongs.count * 8
//    }
//
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let songs = library.allSongs
//        let artists = library.allArtists
//        let albums = library.allAlbums
//        let images = ["killers_album.png", "the_postal_service_album.png", "the_family_crest_album.png", "hozier_album.png", "sf_symphony_album.png"]
//        
//        var cell: UITableViewCell
//        
//        if (indexPath.row == 4) {
//            cell = tableView.dequeueReusableCellWithIdentifier("BigCell", forIndexPath: indexPath)
//        } else {
//            cell = tableView.dequeueReusableCellWithIdentifier("SmallCell", forIndexPath: indexPath)
//        }
//
//        cell.textLabel?.text = "\(songs[indexPath.row % songs.count].name)"
//        cell.detailTextLabel?.text = "\(artists[indexPath.row % artists.count].name) - \(albums[indexPath.row % albums.count].name)"
//        cell.imageView?.image = UIImage(named: images[indexPath.row % images.count])!
//    
//
//        return cell
//    }
//    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        var cell = tableView.cellForRowAtIndexPath(indexPath)
//        if (cell?.reuseIdentifier == "BigCell") {
//            return 100.0
//        }
//        return 50.0
//    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
