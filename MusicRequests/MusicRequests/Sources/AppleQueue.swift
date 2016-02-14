//
//  AppleQueue.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/7/16.
//
//

import Foundation
import MediaPlayer

class AppleQueue: Queue {

  override init(nowPlaying: NowPlaying, sourceLibrary: Library) {
    super.init(nowPlaying: nowPlaying, sourceLibrary: sourceLibrary)
  }

  convenience init(sourceLibrary: Library) {
    self.init(nowPlaying: AppleNowPlaying(), sourceLibrary: sourceLibrary)
  }

}
