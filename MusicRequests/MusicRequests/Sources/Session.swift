//
//  Session.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class Session: NSObject, NSNetServiceDelegate {

  // The constant type used to represent instances of our application.
  static let netServiceType = "_dj194._tcp"

  // Stores the service that is being broadcast/received for this object.
  let netService: NSNetService

  init(netService: NSNetService) {
    self.netService = netService

    super.init()

    self.netService.delegate = self
  }

}
