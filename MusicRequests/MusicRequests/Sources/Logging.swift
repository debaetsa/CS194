//
//  Logging.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/15/16.
//
//

import Foundation

private let fileNameLength = 20
private let functionLength = 40

class Logger {
  // create a shared instance for the entire application
  private static let sharedInstance = Logger()

  // the file handle where the logs should be permanently stored
  private let fileHandle: NSFileHandle?

  private static func createLogDirectory() -> String? {
    if let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last {
      let logDirectoryPath = NSString(string: documentDirectoryPath).stringByAppendingPathComponent("Logs")
      do {
        try NSFileManager.defaultManager().createDirectoryAtPath(logDirectoryPath, withIntermediateDirectories: true, attributes: nil)
        return logDirectoryPath  // return it if it succeeded

      } catch {
        // an error occurred while creating the log directory
      }
    }
    return nil
  }

  init() {
    // create the directory to store the logs
    if let path = Logger.createLogDirectory() {
      var fileName = "\(NSDate())"
      fileName = fileName.stringByReplacingOccurrencesOfString(":", withString: "-")
      fileName = fileName.stringByReplacingOccurrencesOfString("+", withString: " ")
      fileName = fileName.stringByReplacingOccurrencesOfString(" ", withString: "_")
      fileName = NSString(string: fileName).stringByAppendingPathExtension("txt")!
      let filePath = NSString(string: path).stringByAppendingPathComponent(fileName)

      NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
      fileHandle = NSFileHandle(forWritingAtPath: filePath)

    } else {
      fileHandle = nil
    }
  }

  private func log(message: String, file: String, function: String, line: Int) {
    let lastPathComponent = NSString(string: file).lastPathComponent
    let fileName = NSString(string: lastPathComponent).stringByDeletingPathExtension

    let paddedFileName = fileName.stringByPaddingToLength(fileNameLength, withString: " ", startingAtIndex: 0)
    let paddedLineNumber = String(format: ":%4d", line)
    let paddedFunction = function.stringByPaddingToLength(functionLength, withString: " ", startingAtIndex: 0)

    let stringToWrite = "\(NSDate())  \(paddedFileName)\(paddedLineNumber)/\(paddedFunction)  \(message)"
    if let handle = fileHandle {
      handle.writeData(stringToWrite.dataUsingEncoding(NSUTF8StringEncoding)!)
      handle.writeData("\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    print(stringToWrite)
  }
}

func logger(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
  Logger.sharedInstance.log(message, file: file, function: function, line: line)
}
