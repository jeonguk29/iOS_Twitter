//
//  NotificationService.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/14.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct NotificationService {
    static let shared = NotificationService()
    
    // 알림 유형을 전달 할것임
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil) {
        print("DEBUG: Type: is \(type)")
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        // 우리가 여기서 트윗 좋아요를 누르면 트윗 알림은 누군가의 트윗 알림으로 사전 형태로 저장 
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            REF_NOTIFICATIONS
                .child(tweet.user.uid)
                .childByAutoId()
                .updateChildValues(values)
            // 해당 사용자(우기)로 이동하여 해당 사용자에 대한 구조(알림 구조)를 만들고 자식 값을 업데이트합니다.
            // 자식 값 : 시간, 좋아요 누른 트윗 id, 알림 타입(좋아요, 팔로우), 누른 사용자의 uid
        }
        else {

        }


    }

}
