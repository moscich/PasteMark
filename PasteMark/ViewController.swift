//
//  ViewController.swift
//  PasteMark
//
//  Created by Marek Mościchowski on 10.06.2017.
//  Copyright © 2017 Marek Mościchowski. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

  @IBOutlet var tableView:NSTableView!
  var turnedOn = false {
    didSet
    {
      if turnedOn {
      let pasteBoard = NSPasteboard.general()
      pasteBoard.clearContents()
      pasteBoard.writeObjects([self.model[self.currentRow] as NSString])
      self.tableView.selectRowIndexes(IndexSet(integer: self.currentRow), byExtendingSelection: false)
      }
    }
  }
  
  let model = ["Test1\n", "Test2\n", "Test3\n", "Test4\n", "Test5\n"];
  var currentRow = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    self.turnedOn = true
    self.currentRow = self.tableView.selectedRow
    let pasteBoard = NSPasteboard.general()
    pasteBoard.clearContents()
    pasteBoard.writeObjects([self.model[self.currentRow] as NSString])
  }
  
}

