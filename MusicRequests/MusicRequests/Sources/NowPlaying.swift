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

  func didFinishCurrentSong() {
    // Tell the queue to advance to the next song.
    queue.advanceToNextSong()

    // And then tell this instance to play that song.
    playCurrentSong()
  }

  func playCurrentSong() {
  }

  func play() {
    assert(!isPlaying)

    playing = true
    if queue.current == nil {
      queue.advanceToNextSong()
    }
    playCurrentSong()
  }

  func pause() {
    assert(isPlaying)

    playing = false
  }
  
  func next() {
    queue.advanceToNextSong()
    if playing {
      playCurrentSong()
    }
  }
  
  func last() {
    queue.returnToPreviousSong()
    if playing {
      playCurrentSong()
    }
  }
  
  func scrub() {
  }

}
