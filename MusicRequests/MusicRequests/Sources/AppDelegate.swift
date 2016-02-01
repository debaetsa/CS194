//
//  AppDelegate.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var library: Library?
  var queue: Queue?
  var nowPlaying: NowPlaying?

  var localSession: LocalSession!
  var remoteSessionManager: RemoteSessionManager!

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    #if (arch(i386) || arch(x86_64)) && os(iOS)
      let tempLibrary = TemporaryLibrary()
      library = tempLibrary
      nowPlaying = NowPlaying()
      queue = Queue(nowPlaying: nowPlaying!, sourceLibrary: tempLibrary)
    #else
      let appleLibrary = AppleLibrary()
      library = appleLibrary
      nowPlaying = AppleNowPlaying()
      queue = AppleQueue(nowPlaying: nowPlaying!, sourceLibrary: appleLibrary)
    #endif

    nowPlaying?.next()

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

    // start the browser first
    remoteSessionManager = RemoteSessionManager()

    // do some tests with broadcasting the service
    localSession = LocalSession(port: 8000)
    localSession.broadcast()

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

