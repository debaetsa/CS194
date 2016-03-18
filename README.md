~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ JAMM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Copyright 2016. Implementation for CS194, Winter Quarter, Stanford.

~~~~~~~~~~~~~~~~~~~~~~~~~~~ Contributors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 - James Capps
 - Alex De Baets
 - Max Radermacher
 - Matt Volk


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Overview ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

JAMM is a collaborative party playlist application. 

The application allows a group of people to vote on the music, 
allowing all listeners to have a say in what’s playing.  The 
application broadcasts the list of songs in a library, allowing nearby
users to make requests, upvote, and downvote songs.  The broadcasting 
device consolidates this information, using it to choose which songs 
to play.

This product can be used in a variety of situations, ranging from 
smaller environments within a house or an apartment to larger 
organized events (like prom) or by independent radio DJs.


~~~~~~~~~~~~~~~~~~ Source: MusicRequests Directory ~~~~~~~~~~~~~~~~~~~

This directory contains all the major files used to run the app and
is split into four subsections: Temporary, Views, Model, and 
Networking.


### 1.1 Temporary

This directory holds TemporaryLibrary.swift and TemporaryQueue.swift.
Both of these files contain mock library and queue implementations
that allow local testing of the app. These are not used in the 
current build of the app.


### 1.2 Views

- Assets.xcassets: This directory holds all image resources needed for
the app, in 1x, 2x, and 3x sizes to support all iOS devices.

- Main.storyboard: The main UI document for the app. Contains all 
views, subviews, controllers, and transitions.

- Style.swift: Contains all the styling guidelines applied to the 
whole app

- Pluralize.swift: Simple script to aid in pluralizing string output.

- ItemPresentation.swift: Simple extension to the Song class to help
in string output.


## 1.2.1. Swipe Cells

- SwipeTableViewCell, SongTableViewCell, QueueTableViewCell - these
are three extensions to the various types of table view cells that
allow for swipe-to-vote behavior.


## 1.2.2 Sources

- SourceTableViewController and PlaylistSelectionTableViewController -
These work together to control the "Source" screen of the app,
in which a user can decide to broadcast / receive app data.


## 1.2.3 Up Next

- These three files control the main ("Up Next") view of the app.

- MainViewController - controls the main view

- UpNextTableViewController and - NowPlayingView - control the table 
within the main view 


## 1.2.4 Library

- {}TableViewController - controllers for the various table types--
sorted by artist, album, song title, genre, etc.

- SongViewController - Shows the currently playing song

- NowPlayingViewController - Controls the currently playing song and
interfaces with the play/pause/fwd/back/scrubbing buttons on the host
device.


### 1.3 Model

## 1.3.1 Items

- Artist, Genre, Song, Album, and Playlist all inherit from the 
general Item class. These classes are used to store, sort, and keep
track of library data.

## 1.3.2 Library 

- Library.swift - general class for keeping track of all the data 
associated with a user's library

- AppleLibrary - subclass of library that deals with Apple's backend
to read data from the local device

- FilteredLibrary - used to send / look at only a portion of the whole
library object, also a subclass of Library

## 1.3.3 Playing

- Queue - Keeps track of the list of upcoming, previously played, and
currently playing song(s). 

- QueueItem - Instance of an item in the queue--keeps song data and
metadata (vote count, etc.)

- Request - A request object used to request songs

- AppleQueue - Used by queue to interface with the iOS backend queue

- NowPlaying - Used by queue to keep track of the currently playing 
song

- AppleNowPlaying - Used to interface with the iOS backend currently
playing song


### 1.4 Networking

## 1.4.1 Session

- Session, LocalSession, and RemoteSession - Session objects used to 
keep track of sockets, incoming/outgoing data

- Connection - Used to track a particular connection state, including
sockets and metadata.

- RemoteSessionManager - manages remote sessions

## 1.4.2 Other

- Sendable.swift - A class used to abstract a sendable (serializable) 
object

- CustomAlbumArt - Extension of Album class used for serializing and
sending album art

- Remote Library / Remote Queue - Used to handle the library / queue
objects in the remote case.







