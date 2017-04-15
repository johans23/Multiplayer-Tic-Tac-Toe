//
//  ViewController.swift
//  Tic Tac Toe
//
//  Created by Sajan Thomas on 12/30/14.
//  Copyright (c) 2014 Jojo Inc. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    @IBOutlet var fields: [TTTImageView]!
    var currentPlayer:String!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        setupField()
        currentPlayer = "X"
        
    }
    
    
    @IBAction func connectWithPlayer(sender: AnyObject) {
        
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    func peerChangedStateWithNotification(notification:NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as Int
        
        if state != MCSessionState.Connecting.toRaw(){
            self.navigationItem.title = "Connected"
        }
        
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.objectForKey("string")?.isEqualToString("New Game") == true{
            let alert = UIAlertController(title: "TicTacToe", message: "\(senderDisplayName) has started a new Game", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            resetField()
        }else{
            var field:Int? = message.objectForKey("field")?.integerValue
            var player:String? = message.objectForKey("player") as? String
            
            if field != nil && player != nil{
                fields[field!].player = player
                fields[field!].setPlayer(player!)
                
                if player == "X"{
                    currentPlayer = "O"
                }else{
                    currentPlayer = "X"
                }
                
                checkResults()
                
            }
            
        }
        
        
    }
    
    
    func fieldTapped (recognizer:UITapGestureRecognizer){
        let tappedField  = recognizer.view as TTTImageView
        tappedField.setPlayer(currentPlayer)
        
        let messageDict = ["field":tappedField.tag, "player":currentPlayer]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        
        checkResults()
        
        
    }
    
    
    func setupField (){
        for index in 0 ... fields.count - 1{
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: "fieldTapped:")
            gestureRecognizer.numberOfTapsRequired = 1
            
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func resetField(){
        for index in 0 ... fields.count - 1{
            fields[index].image = nil
            fields[index].activated = false
            fields[index].player = ""
        }
        
        currentPlayer = "X"
    }
    @IBAction func newGame(sender: AnyObject) {
        resetField()
        
        let messageDict = ["string":"New Game"]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        
        
    }

    func checkResults(){
        var winner = ""
        
        if fields[0].player == "X" && fields[1].player == "X" && fields[2].player == "X"{
            winner = "X"
        }else if fields[0].player == "O" && fields[1].player == "O" && fields[2].player == "O"{
            winner = "O"
        }else if fields[3].player == "X" && fields[4].player == "X" && fields[5].player == "X"{
            winner = "X"
        }else if fields[3].player == "O" && fields[4].player == "O" && fields[5].player == "O"{
            winner = "O"
        }else if fields[6].player == "X" && fields[7].player == "X" && fields[8].player == "X"{
            winner = "X"
        }else if fields[6].player == "O" && fields[7].player == "O" && fields[8].player == "O"{
            winner = "O"
        }else if fields[0].player == "X" && fields[3].player == "X" && fields[6].player == "X"{
            winner = "X"
        }else if fields[0].player == "O" && fields[3].player == "O" && fields[6].player == "O"{
            winner = "O"
        }else if fields[1].player == "X" && fields[4].player == "X" && fields[7].player == "X"{
            winner = "X"
        }else if fields[1].player == "O" && fields[4].player == "O" && fields[7].player == "O"{
            winner = "O"
        }else if fields[2].player == "X" && fields[5].player == "X" && fields[8].player == "X"{
            winner = "X"
        }else if fields[2].player == "O" && fields[5].player == "O" && fields[8].player == "O"{
            winner = "O"
        }else if fields[0].player == "X" && fields[4].player == "X" && fields[8].player == "X"{
            winner = "X"
        }else if fields[0].player == "O" && fields[4].player == "O" && fields[8].player == "O"{
            winner = "O"
        }else if fields[2].player == "X" && fields[4].player == "X" && fields[6].player == "X"{
            winner = "X"
        }else if fields[2].player == "O" && fields[4].player == "O" && fields[6].player == "O"{
            winner = "O"
        }
        
        if winner != ""{
            let alert = UIAlertController(title: "Tic Tac Toe", message: "The winner is \(winner)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction!) -> Void in
                self.resetField()
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



