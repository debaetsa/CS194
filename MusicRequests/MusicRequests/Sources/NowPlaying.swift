//
//  NowPlaying.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class NowPlaying: NSObject {

  private var playingQueueItem: QueueItem?

  var generator: (Void -> QueueItem?)?

  override init() {
    super.init()
  }

  var isPlaying: Bool {
    return false
  }

  func findQueueItemToPlay() -> QueueItem? {
    if playingQueueItem == nil {
      if let pickNextSong = generator {
        playingQueueItem = pickNextSong()
      }
    }
    return playingQueueItem
  }

  func didFinishCurrentQueueItem() -> Void {
    // Reset this so that we get the
    playingQueueItem = nil
  }

  var currentQueueItem: QueueItem? {
    return playingQueueItem
  }

  func play() {
  }

}
