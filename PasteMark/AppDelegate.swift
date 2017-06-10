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

}

