//
//  AppleNowPlaying.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/7/16.
//
//

import Foundation
import MediaPlayer

class AppleNowPlaying: LocalNowPlaying {

  ///////////////////////
  // PRIVATE VARIABLES //
  ///////////////////////

  let musicPlayer: MPMusicPlayerController

  override init() {
    // Create the music player that we will use to play the songs.  We also
    // disable shuffle/repeat since we want songs played in the proper order.
    // We MUST use the applicationMusicPlayer since we want the application to
    // continue running while in the background.  We also don't want to mess
    // with what is playing in the "Music" application -- that's annoying.
    musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    musicPlayer.shuffleMode = MPMusicShuffleMode.Off
    musicPlayer.repeatMode = MPMusicRepeatMode.None

    super.init()

    // Register after the initialization code has had a chance to complete.
    let center = NSNotificationCenter.defaultCenter()
    center.addObserver(self, selector: "didChangeNowPlaying:", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
    center.addObserver(self, selector: "didChangePlaybackState:", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
    musicPlayer.beginGeneratingPlaybackNotifications()
  }

  deinit {
    let center = NSNotificationCenter.defaultCenter()
    center.removeObserver(self, name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer)
    center.removeObserver(self, name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
    musicPlayer.endGeneratingPlaybackNotifications()
  }

  func didChangeNowPlaying(note: NSNotification) -> Void {
  }

  func didChangePlaybackState(note: NSNotification) -> Void {
    if isPlaying {
      // We're supposed to be playing…
      if musicPlayer.playbackState == MPMusicPlaybackState.Stopped && musicPlayer.nowPlayingItem == nil {
        // …but we're paused, which is what happens when the Song ends.
        didFinishCurrentSong()

        // After we do this, the player will transition to "Stop" and then
        // "Playing", so we need to be aware of that.
      }
    }
  }

  override func playCurrentSong() {
    if let toPlay = self.queue.current {
      let mediaItem = toPlay.song.userInfo as! MPMediaItem
      musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: [ mediaItem ]))

      // VERYHELPFUL
      // If you uncomment this line, it'll just play the last 20 seconds of
      // each song.  This makes it much easier to test transitions.

      // musicPlayer.currentPlaybackTime = mediaItem.playbackDuration - 20

      musicPlayer.play()
    } else {
      // We couldn't find a Song to play, so mark it as having stopped.
      playing = false
    }
  }

  override func pause() -> Void {
    assert(isPlaying)

    playing = false //this took me a while to figure out why every time I paused it kept playing again.
    musicPlayer.pause()
  }
  
  override func scrub(value : Double) {
    musicPlayer.currentPlaybackTime = value
  }
  
  override var currentPlaybackTime: NSTimeInterval? {
    return musicPlayer.currentPlaybackTime
  }
  
  override var currentPlaybackDuration: NSTimeInterval? {
    return musicPlayer.nowPlayingItem?.playbackDuration
  }
}
