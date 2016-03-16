//
//  Logging.swift
//  MusicRequests
//
//  Created by Max Radermacher on 3/15/16.
//
//

import Foundation

private let fileNameLength = 25
private let functionLength = 40

func logger(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
  let lastPathComponent = NSString(string: file).lastPathComponent
  let fileName = NSString(string: lastPathComponent).stringByDeletingPathExtension

  let paddedFileName = "\(fileName):\(line)".stringByPaddingToLength(fileNameLength, withString: " ", startingAtIndex: 0)
  let paddedFunction = function.stringByPaddingToLength(functionLength, withString: " ", startingAtIndex: 0)

  print("\(paddedFileName)/\(paddedFunction)  \(message)")
}
