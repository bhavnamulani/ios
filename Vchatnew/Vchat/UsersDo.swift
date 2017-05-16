//
//  UsersDao.swift
//  XMPP
//
//  Created by Ranjit singh on 4/26/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import Foundation
import UIKit
class UsersDo {
    
    var name: String?
    var username: String?
    var email: String?
    var lastMessageReceived: String?
    var unReadMsgCount: Int? 
    
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        //print("name: ", self.name)
        
        self.username = json["username"] as? String
        //print("username: ",self.username)
        
        self.email = json["email"] as? String
        //print("email: ", self.email)
        
        self.lastMessageReceived = json["lastMessageReceived"] as? String
        //print("last msg rec: ", self.lastMessageReceived)
        
        self.unReadMsgCount = json["unReadMsgCount"] as? Int
        //print("un read msg cout: ",self.unReadMsgCount)

    }
}
