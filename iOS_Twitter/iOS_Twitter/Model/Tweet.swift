//
//  Tweet.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/21.
//

import UIKit

// 트윗을 담을 모델
struct Tweet{
    let caption: String
    let tweetID: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    let user:User
    var didLike = false // Is follow 했던 것과 거의 똑같은 개념 이속성을 이용해 좋아요 누른것을 기억하고 처리하는 작업을 할것임 
    // 모델을 조금 더 세분화하면 사용자 없이 트윗이 존재할 수 없습니다.
    // 따라서 모든 트윗은 누군가의 것이어야 합니다.
    
    
    init(user: User ,tweetID: String, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweetCount"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
      
    }
}
