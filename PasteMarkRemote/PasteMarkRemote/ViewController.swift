//
//  ViewController.swift
//  PasteMarkRemote
//
//  Created by Marek Mościchowski on 15.06.2017.
//  Copyright © 2017 Marek Mościchowski. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, NetServiceBrowserDelegate , NetServiceDelegate, GCDAsyncSocketDelegate{

  var serviceBrowser : NetServiceBrowser?
  var service : NetService?
	var sock: GCDAsyncSocket?
  var connectedSock: GCDAsyncSocket?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    serviceBrowser = NetServiceBrowser()
    serviceBrowser?.delegate = self
    serviceBrowser?.searchForServices(ofType: "_paste._tcp", inDomain: "")
    
    sock = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    if !moreComing {
      self.service = service
      service.delegate = self
      service.resolve(withTimeout: 10)
    }
    print("net service = \(service)")
    
    
    
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    guard let data = service.addresses?.first else { return }
    do {
      try data.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
        guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
          throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
        }
      }
    } catch {
      print(error)
      return
    }
    let address = String(cString:hostname)
    print(address)

  }
  
  func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
    print("net domain = \(domainString)")
  }
  
  func netServiceDidResolveAddress(_ sender: NetService) {
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    guard let data = sender.addresses?.first else { return }
    do {
      try data.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
        guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
          throw NSError(domain: "domain", code: 0, userInfo: ["error":"unable to get ip address"])
        }
      }
    } catch {
      print(error)
      return
    }
    let address = String(cString:hostname)
    print(address)
    
    do {
      try sock?.connect(toHost: address, onPort: 8889)
    } catch {
      print("erorr")
    }
  }
  
  func netServiceWillResolve(_ sender: NetService) {
    print("will")
  }
  
  func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    let data = "Hello yo!".data(using: .utf8)
    connectedSock = sock
    sock.write(data!, withTimeout: 10, tag: 0)
//    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
  }
  
  func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    print("did write yo")
  }
  
}
