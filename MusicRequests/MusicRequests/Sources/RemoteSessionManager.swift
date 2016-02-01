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

  override init() {
    netServiceBrowser = NSNetServiceBrowser()

    super.init()

    netServiceBrowser.delegate = self
    netServiceBrowser.searchForServicesOfType(Session.netServiceType, inDomain: "")
  }

  func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {
    print("will search")
  }

  func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
    print("will stop searching")
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
    print("didFindService: \(service)")
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
    print("didRemoveService: \(service)")
  }

  func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    print("did not search: \(errorDict)")
  }

}
