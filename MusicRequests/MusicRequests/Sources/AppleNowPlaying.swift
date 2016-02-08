//
//  AppleNowPlaying.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/7/16.
//
//

import Foundation
import MediaPlayer

class AppleNowPlaying: NowPlaying {

  ///////////////////////
  // PRIVATE VARIABLES //
  ///////////////////////

  let musicPlayer: MPMusicPlayerController

  override init() {
    // Create the music player that we will use to play the songs.  We also
    // disable shuffle/repeat since we want songs played in the proper order.
    // The Music player should be a systemMusicPlayer, not an applicationMusicPlayer
    // applicationMusicPlayers would require the app to open while playing, which
    // is not what we want.
    musicPlayer = MPMusicPlayerController.systemMusicPlayer()
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
      // Not always, for example when the user hits pause on the control screen.
      if musicPlayer.playbackState == MPMusicPlaybackState.Paused {
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

}
