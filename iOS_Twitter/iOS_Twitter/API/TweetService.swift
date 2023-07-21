//
//  TweetService.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/20.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, completion: @escaping(Error?, DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        
        let values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes" : 0, "retweets": 0, "caption": caption] as [String : Any]
        
        REF_TWEETS.childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
    
    // 트윗 가져오는 메서드 만들기
    func fatchTweets(completion: @escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            print("DEBUG: Snapshot is \(snapshot.value)")
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let tweetID = snapshot.key // 각 트윗의 키를 얻을 수 있음
            let tweet = Tweet(tweetID: tweetID, dictionary: dictionary)
            tweets.append(tweet)// 모든 트윗을 찾아 담고 반환 
            completion(tweets)
        }
    }
    
    
}
