//
//  LocalSession.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class LocalSession: Session {

  init(port: Int32) {
    super.init(netService:NSNetService(domain: "", type: LocalSession.netServiceType, name: "", port: port))
  }

  func broadcast() -> Void {
    self.netService.publish()
  }

  func netServiceWillPublish(sender: NSNetService) {
    print("Will publish: \(sender)")
  }

  func netServiceDidPublish(sender: NSNetService) {
    print("Published NSNetService: \(sender)")
  }

  func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
    print("Could not publish: \(sender): \(errorDict)")
  }

}
