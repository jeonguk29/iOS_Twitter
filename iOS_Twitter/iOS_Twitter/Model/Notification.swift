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

    let tweetID: String?
    var timestamp: Date!
    let user: User
    var tweet: Tweet?
    var type: NotificationType!

    init(user: User, tweet: Tweet?, dictionary: [String: AnyObject]) {
        self.user = user
        self.tweet = tweet

        self.tweetID = dictionary["tweetID"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }

        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
