//
//  AppDelegate.swift
//  PasteMark
//
//  Created by Marek Mościchowski on 10.06.2017.
//  Copyright © 2017 Marek Mościchowski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



  func applicationDidFinishLaunching(_ aNotification: Notification) {
    print("AXIsProcessTrusted \(AXIsProcessTrusted())")
  }

  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    print("filename = \(filename)")
    
      let string = try? String.init(contentsOfFile: filename)
      print("string = \(string)")
    
      let array = string?.components(separatedBy: "////\n")
    let vc = NSApp.keyWindow?.contentViewController as! ViewController
    vc.model = array!
    
    return true
  }
  
}

