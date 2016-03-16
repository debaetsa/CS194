//
//  RemoteSessionManager.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/1/16.
//
//

import UIKit

class RemoteSessionManager: NSObject, NSNetServiceBrowserDelegate {

  static let didUpdateNotification = "jamm.RemoteSessionManager.didUpdate"

  private let netServiceBrowser: NSNetServiceBrowser

  private var remoteSessions = [RemoteSession]()
  var sessions: [RemoteSession] {
    return remoteSessions
  }

  override init() {
    netServiceBrowser = NSNetServiceBrowser()

    super.init()

    netServiceBrowser.delegate = self
    netServiceBrowser.searchForServicesOfType(RemoteSession.netServiceType, inDomain: "")
  }

  func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
  }

  func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
  }

  private func postUpdatedNotification() {
    let center = NSNotificationCenter.defaultCenter()
    center.postNotificationName(RemoteSessionManager.didUpdateNotification, object: self)
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
    logger("found service with name \(service.name)")

    remoteSessions.append(RemoteSession(netService: service))

    if !moreComing {
      postUpdatedNotification()
    }
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {

    var serviceIndex: Int?
    for (index, session) in remoteSessions.enumerate() {
      if session.netService == service {
        serviceIndex = index
        break
      }
    }

    var session: RemoteSession? = nil
    if let indexToRemove = serviceIndex {
      session = remoteSessions.removeAtIndex(indexToRemove)
    }
    logger("removed session \(session?.name)")

    if !moreComing {
      postUpdatedNotification()
    }
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    print("did not search: \(errorDict)")
  }

}
