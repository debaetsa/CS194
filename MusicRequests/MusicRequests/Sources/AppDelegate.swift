//
//  AppDelegate.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//  Copyright © 2016 Capps, De Baets, Radermacher, Volk. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  static let didChangeSession = "AppDelegate.didChangeSession"

  /** Gets a reference to the shared application delegate.

   This is unwrapped with "!" since the application cannot possibly work if
   this is not the case.  It's not a recoverable error. */
  static var sharedDelegate: AppDelegate {
    return (UIApplication.sharedApplication().delegate as? AppDelegate)!
  }

  var window: UIWindow?

  // we always need a reference to our session that stores the configuration
  var localSession: LocalSession!

  // and this is the one we actually use for data (could be local or remote)
  var currentSession: Session! {
    willSet {
      // disconnect if this is a RemoteSession
      if let remoteSession = currentSession as? RemoteSession {
        remoteSession.disconnect()
      }
    }
    didSet {
      if let remoteSession = currentSession as? RemoteSession {
        remoteSession.connect()
      }
      let center = NSNotificationCenter.defaultCenter()
      center.postNotificationName(AppDelegate.didChangeSession, object: self)
    }
  }

  // this is how we find the other sessions; it's put here so that it's always
  // looking; this way the data is ready when the user taps "sources"
  var remoteSessionManager: RemoteSessionManager!

  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    // change the color theme of the app
    Style.darkTheme.standardView()

    #if (arch(i386) || arch(x86_64)) && os(iOS)
      let library = TemporaryLibrary()
      let queue = LocalQueue(library: library)
    #else
      let library = AppleLibrary()
      let queue = AppleQueue(sourceLibrary: library)
    #endif

    // advance to the next song so that something is always playing
    (queue.nowPlaying as! LocalNowPlaying).next()

    // start the browser first
    remoteSessionManager = RemoteSessionManager()

    // do some tests with broadcasting the service
    localSession = LocalSession(library: library, queue: queue)
    currentSession = localSession  // start with the local session

    // VERYHELPFUL
    // Uncomment the following block to automatically start playing two seconds
    // after the application launches.

    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
      self.queue?.nowPlaying.play()
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
      self.queue?.nowPlaying.next()
      self.queue?.nowPlaying.next()
      self.queue?.nowPlaying.next()
    }
    */

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

