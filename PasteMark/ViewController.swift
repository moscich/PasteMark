//
//  ViewController.swift
//  PasteMark
//
//  Created by Marek Mościchowski on 10.06.2017.
//  Copyright © 2017 Marek Mościchowski. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

enum MessageType:Int {
  case contents = 0
  case select = 1
  case stop
  case next
}

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, GCDAsyncSocketDelegate, NetServiceDelegate {

  @IBOutlet var tableView:NSTableView!
  var sock: GCDAsyncSocket?
  var newSock: GCDAsyncSocket?
  var service: NetService?
  var turnedOn = false {
    didSet
    {
      if turnedOn {
      let pasteBoard = NSPasteboard.general()
      pasteBoard.clearContents()
      pasteBoard.writeObjects([self.model[self.currentRow] as NSString])
      self.tableView.selectRowIndexes(IndexSet(integer: self.currentRow), byExtendingSelection: false)
      self.sendSelectAtIndex(index: self.currentRow)
      }
    }
  }
  
  var model = ["Test1\nTest\n\n\nHej hej hej", "Test2\n", "Test3\n", "Test4\n", "Test5\n"] {
    didSet{
      self.tableView.reloadData()
    }
  }
  var currentRow = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.registerBonjour(port: 8889)
    
    sock = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    
    do {
      try sock?.accept(onPort: 8889)
    } catch  {
      print("error = ")
    }
    
    NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown) {
      event in
      if self.turnedOn, event.modifierFlags.contains(NSEventModifierFlags.command), event.characters == "v" {
        let deadlineTime = DispatchTime.now() + .milliseconds(100)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
          let pasteBoard = NSPasteboard.general()
          pasteBoard.clearContents()
          self.currentRow += 1
          if self.model.count > self.currentRow {
            pasteBoard.writeObjects([self.model[self.currentRow] as NSString])
            self.tableView.selectRowIndexes(IndexSet(integer: self.currentRow), byExtendingSelection: false)
            self.sendSelectAtIndex(index: self.currentRow)
          } else {
            self.turnedOn = false
          }
        }
        
      }
    }
    
    NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown) {
      event in
      if event.modifierFlags.contains(NSEventModifierFlags.command) && (event.characters == "c" || event.characters == "x"){
        self.turnedOn = false
      }
    }
    
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  func numberOfRows(in tableView: NSTableView) -> Int {
    return model.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    if let cell = tableView.make(withIdentifier: "hello", owner: nil) as? NSTableCellView{
      cell.textField?.stringValue = model[row]
      return cell
    }
    return nil
  }
  
  @IBAction func selectionChanged(obj:Any) {
    self.currentRow = self.tableView.selectedRow
    self.turnedOn = true
    let pasteBoard = NSPasteboard.general()
    pasteBoard.clearContents()
    pasteBoard.writeObjects([self.model[self.currentRow] as NSString])
  }
  
  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    print("Accept yo = \(newSocket)")
    let data = try? JSONSerialization.data(withJSONObject: self.model)
    newSock = newSocket
    newSock?.delegate = self
    
    newSock?.write(data!, withTimeout: 10, tag: MessageType.contents.rawValue)
  }
  
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    print("Connected yo = \(host)")
  }
  
  func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    print("data= \(String.init(data: data, encoding: .utf8))")
  }
  
  func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
    print("partial = \(partialLength)")
  }
  
  func registerBonjour(port:Int32) {
    self.service = NetService(domain: "", type: "_paste._tcp", name: "", port:port)
    self.service?.delegate = self
    self.service?.publish()
  }
  
  func sendSelectAtIndex(index:Int) {
    let data = "\(index)".data(using: .utf8)
    newSock?.write(data!, withTimeout: 10, tag: 1)
  }
}

