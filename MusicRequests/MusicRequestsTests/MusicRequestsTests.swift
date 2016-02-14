//
//  MusicRequestsTests.swift
//  MusicRequestsTests
//
//  Created by Max Radermacher on 1/24/16.
//
//

import XCTest
@testable import MusicRequests

class MusicRequestsTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    //I've been playing with the tests, haven't been able to get them working locally due to XCode configuartion stuff, so this is still kind of my playground right now. I'll push something better once I get these working.
    
    let artist = Artist()
    artist.name = "Bon Iver"
    
    let song = Song();
    song.name = "Towers"
    
    var artists = Set<Artist>()
    artists.insert(artist)
    
    song.artists = artists
    
    let album = Album()
    album.name = "Bon Iver"
    album.artists = artists
    
    let albumTrack = Track()
    albumTrack.album = album
    albumTrack.song = song
    albumTrack.songNumber = 1
    albumTrack.discNumber = 1
    
    var tracks = Set<Track>()
    tracks.insert(albumTrack)
    album.tracks = tracks
    
    print(album.name);
    print(album.artists);
    
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }

}
