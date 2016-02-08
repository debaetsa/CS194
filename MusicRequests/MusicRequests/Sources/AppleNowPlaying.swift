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

  let musicPlayer: MPMusicPlayerController

  override init() {
    // Create the music player that we will use to play the songs.  We also
    // disable shuffle/repeat since we want songs played in the proper order.
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
    print("Did change NowPlaying")
  }

  func didChangePlaybackState(note: NSNotification) -> Void {
    print("Did change playback state: \(String(reflecting: musicPlayer.playbackState))")
  }

  override var isPlaying: Bool {
    return musicPlayer.playbackState == MPMusicPlaybackState.Playing
  }

  override func play() -> Void {
    assert(!isPlaying)  // make sure that nothing is playing

    // and then figure out what we need to play
    if let toPlay = self.findQueueItemToPlay() {
      musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: [ (toPlay.song.userInfo as! MPMediaItem) ]))
      musicPlayer.play()
    } else {
      print("Could not find a song to play.")
    }
  }

  override func pause() -> Void {
    assert(isPlaying)

    musicPlayer.pause()
  }

}
