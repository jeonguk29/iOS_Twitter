//
//  User.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/18.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct User {
    let fullname: String
    let email: String
    let username: String
    var profileImageUrl: URL?
    let uid: String
    
    // 사용자가 현재 사용자인지 여부를 파악하기 위한 변수
    var isCurrentUser: Bool {return Auth.auth().currentUser?.uid == uid}
    
    init(uid: String, dictionary: [String: AnyObject]){
        self.uid = uid
        
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else {return}
            self.profileImageUrl = url
        }
        
    }
}
