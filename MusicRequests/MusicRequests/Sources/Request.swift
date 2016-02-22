//
//  SongRequest.swift
//  MusicRequests
//
//  Created by Max Radermacher on 2/21/16.
//
//

import Foundation

enum Request: Sendable {

  enum Voted: UInt8 {
    case None = 0
    case Up
    case Down
  }

  // allow a song to be requested
  case Song(MusicRequests.Song, Voted)

  // and allow a QueueItem to be requested
  case QueueItem(MusicRequests.QueueItem, Voted)


  // MARK: - Sending

  enum Tag: UInt8 {
    case Song = 1
    case QueueItem
  }

  var sendableIdentifier: SendableIdentifier {
    return .Request
  }

  var sendableData: NSData {
    // these are what will be sent for the Request
    var tag: Tag
    var identifier: UInt32
    let voted: Voted

    // so construct them from the object
    switch self {
    case .Song(let song, let boundVoted):
      tag = .Song
      identifier = song.identifier
      voted = boundVoted

    case .QueueItem(let queueItem, let boundVoted):
      tag = .QueueItem
      identifier = queueItem.identifier
      voted = boundVoted
    }

    // build the data object that will be sent
    let data = NSMutableData()
    data.appendByte(tag.rawValue)
    data.appendByte(voted.rawValue)
    data.appendCustomInteger(identifier)
    return data
  }

  init?(data: NSData, lookup: [UInt32: Item], queue: Queue) {
    var offset = 0
    guard let type = data.getNextByte(&offset) else {
      return nil
    }

    guard let votedRawValue = data.getNextByte(&offset) else {
      return nil
    }

    guard let voted = Voted(rawValue: votedRawValue) else {
      return nil
    }

    guard let identifier = data.getNextInteger(&offset) else {
      return nil
    }

    guard let tag = Tag(rawValue: type) else {
      return nil  // and invalid identifier was specified
    }

    switch tag {
    case .Song:
      if let item = lookup[identifier], let song = item as? MusicRequests.Song {
        self = .Song(song, voted)
      } else {
        return nil
      }

    case .QueueItem:
      if let queueItem = queue.itemForIdentifier(identifier) {
        self = .QueueItem(queueItem, voted)
      } else {
        return nil
      }
    }
  }
}
