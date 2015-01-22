//
//  AppDelegate.swift
//  Stall Monitor
//
//  Created by Todd Resudek on 1/16/15.
//  Copyright (c) 2015 supersimple. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var currentStateLabel: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    let icon = NSImage(named: "statusIcon")
    let iconOpen = NSImage(named: "statusIconOpen")
    
    let url = NSURL(string: "http://supersimple.org/stallmonitor/status.html")!
    
    var occupied = false;
    
    let session = NSURLSession.sharedSession()
    
    //This function will be called on intervals to check web service for updates in the status
    func lookForUpdate(){
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            let results: NSDictionary = jsonResult as NSDictionary
            dispatch_async(dispatch_get_main_queue(), {
                self.occupied = results["status"] as Bool
                self.updateStatusIcon();
            })
        })
        
        task.resume()
    }
    
    func updateStatusIcon(){
        if(occupied == false){
            statusItem.image = iconOpen
            currentStateLabel.title = "Unoccupied"
        }else{
            statusItem.image = icon
            currentStateLabel.title = "Occupied"
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        statusItem.image = iconOpen
        statusItem.menu = statusMenu
        currentStateLabel.title = "Unoccupied"
        currentStateLabel.state = NSOffState
        
        NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: "lookForUpdate", userInfo: nil, repeats: true)
        
        ensureLaunchAtStartup()
    }
    
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                println("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as LSSharedFileListItemRef
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            println("URL Ref: \(urlRef.lastPathComponent)")
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        println("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    func ensureLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if shouldBeToggled {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    )
                    println("Application was added to login items")
                }
            } else {
                //do nothing, already in the startup items
                println("Already in the startup items.")
            }
        }
    }
    
    
    @IBAction func quitMenu(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self) //this quits the app
    }
    
}

