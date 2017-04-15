//
//  TTTImageVIew.swift
//  Tic Tac Toe
//
//  Created by Sajan Thomas on 1/9/15.
//  Copyright (c) 2015 Jojo Inc. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {

    var player: String?
    var activated: Bool! = false
    
    func setPlayer (_player:String){
        self.player = _player
        
        if activated == false{
            if _player == "X"{
                self.image = UIImage(named: "X")
            }else{
                self.image = UIImage(named: "O")
            }
            activated = true
        }
        
    }
        
    

}
