//
//  WindowController.swift
//  PasteMark
//
//  Created by Marek Mościchowski on 10.06.2017.
//  Copyright © 2017 Marek Mościchowski. All rights reserved.
//

import Foundation

class WindowController: NSWindowController {
  
//  @IBOutlet var viewController : ViewController!
  
  @IBAction func toolbarClicked(button:NSToolbarItem) {
    let vc = self.contentViewController as! ViewController
    vc.turnedOn = !vc.turnedOn
    print("button = \(button)")
  }
  
}
