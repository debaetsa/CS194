//
//  NowPlaying.swift
//  MusicRequests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import UIKit

class NowPlaying: NSObject {

  var playing = false

  // This would ideally be "unowned", which operates very similarly to this,
  // but we can't make that work since the unowned value shouldn't be optional.
  // By writing it this way, it can be set after initialization, but it will
  // still throw an error if it is ever unexpectedly NOT set.
  weak var queue: Queue!

  override init() {
    super.init()
  }

  var isPlaying: Bool {
    return playing
  }

}

class LocalNowPlaying: NowPlaying {
  /** This must be associated with a LocalQueue object. */
  var localQueue: LocalQueue {
    return queue as! LocalQueue
  }

  func didFinishCurrentSong() {
    // Tell the queue to advance to the next song.
    localQueue.advanceToNextSong()

    // And then tell this instance to play that song.
    playCurrentSong()
  }

  func playCurrentSong() {
  }

  func play() {
    assert(!isPlaying)

    playing = true
    if queue.current == nil {
      localQueue.advanceToNextSong()
    }
    playCurrentSong()
  }

  func pause() {
    assert(isPlaying)

    playing = false
  }

  func next() {
    localQueue.advanceToNextSong()
    if playing {
      playCurrentSong()
    }
  }

  func last() {
    localQueue.returnToPreviousSong()
    if playing {
      playCurrentSong()
    }
  }

  func scrub(value: Double) {
  }
  
  func currentPlayBackTime() -> Double{
    return 10.0;
  }
  
  func currentPlayBackDuration() -> Double {
    return 0.0;
  }
}
