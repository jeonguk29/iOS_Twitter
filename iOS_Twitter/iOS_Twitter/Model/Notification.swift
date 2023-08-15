//
//  Notification.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/14.
//

import Foundation


enum NotificationType: Int { // 어떤 종류의 알림인지 숫자로 파악하기 위함
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {

    var tweetID: String?
    var timestamp: Date!
    var user: User
    var tweet: Tweet?
    var type: NotificationType!

    init(user: User, dictionary: [String: AnyObject]) {
        self.user = user
        
        // 알림 중에 팔로우 했다는 알림을 눌렀을때 크레시가 나는걸 방지하기 위해 수정
        // 트윗 알림시 해당 트윗을 보여주고 그렇지 않다면 nil을 반환해서 크래시는 나지 않음 
        if let tweetID = dictionary["tweetID"] as? String {
            self.tweetID = tweetID
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }

        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
