//
//  User.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/18.
//

import Foundation

struct User {
    let fullname: String
    let email: String
    let username: String
    let profileImageUrl: String
    let uid: String
    
    init(uid: String, dictionary: [String: AnyObject]){
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
