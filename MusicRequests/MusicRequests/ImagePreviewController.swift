//
//  ImagePreviewController.swift
//  MusicRequests
//
//  Created by Matthew Volk on 2/7/16.
//
//

import UIKit

class ImagePreviewController: UIViewController {
  
  var albumArt: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(patternImage: resizeImage(albumArt!))
  }
  
  func resizeImage(image: UIImage) -> UIImage {
    let screenWidth = UIScreen.mainScreen().bounds.size.width;
    let newSize = CGSizeMake(screenWidth, screenWidth)
    let rect = CGRectMake(0,0, newSize.width, newSize.height)
    UIGraphicsBeginImageContext(newSize)
    image.drawInRect(rect)
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return scaledImage
  }


}
