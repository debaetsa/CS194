//
//  RemoteSessionManager.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/1/16.
//
//

import UIKit

class RemoteSessionManager: NSObject, NSNetServiceBrowserDelegate {

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

  func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {

    remoteSessions.append(RemoteSession(netService: service))

    if !moreComing {
      // Send out a notification since we have received some of the services.
    }
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {

    var serviceIndex: Int?
    for (index, session) in remoteSessions.enumerate() {
      if session.netService === service {
        serviceIndex = index
        break
      }
    }
    if let indexToRemove = serviceIndex {
      remoteSessions.removeAtIndex(indexToRemove)
    }
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    print("did not search: \(errorDict)")
  }

}
