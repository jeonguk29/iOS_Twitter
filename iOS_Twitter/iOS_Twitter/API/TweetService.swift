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
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        // 누가 트윗을 남겼는지 uid를 저장해줘야함
        
        let values = ["uid": uid, "timestamp" : Int(NSDate().timeIntervalSince1970),
                      "likes" : 0, "retweets": 0, "caption": caption] as [String : Any]
        
        // 파이어 베이스에 답장 업로드하기
        switch type {
        case .tweet:
            REF_TWEETS.childByAutoId().updateChildValues(values) { (error, ref) in
                // update user-tweet structure after tweet upload completes
                guard let tweetID = ref.key else { return }
                REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            // 답글일때는 기준 트윗 아이디 밑에 답글 트윗 을 생성
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values, withCompletionBlock: completion)
        }
                                    
        let ref =  REF_TWEETS.childByAutoId()
        
        // 트윗이 생성 될때 만들어지는 자동 ID 안에 : 여기에 사용자가 작성한 모든 값을 자식으로 업데이트
        ref.updateChildValues(values) {  (err, ref) in
            // 파이어 베이스에 저장이 된 이후
            // 이 코드는 트윗 업로드가 완료된 후 사용자 트윗 구조를 업데이트할 곳입니다.
            guard let tweetID = ref.key else {return}
            
            // 작성한 사용자의 uid가 최종 부모 값이고 그 아래에 트윗 key를 저장
            // 따라서 궁극적으로 우리는 사용자가 어떤 트윗을 작성했는지 알아낼 수 있을 것입니다.
            // 이런것을 팬 아웃이라고 하며 : 서버 작업이 훨씬 줄어듬
            REF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
        }
    }
    
    // 트윗 가져오는 메서드 만들기
    func fatchTweets(completion: @escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        
        REF_TWEETS.observe(.childAdded) { snapshot in
            print("DEBUG: Snapshot is \(snapshot.value)")
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            //트윗 내부에 사용자 uid를 저장했음, 해당 uid는 user테이블의 키와 값음 해당 값을 이용하여 사용자를 가져와 트윗 모델에 전달 할 것임
            let tweetID = snapshot.key // 각 트윗의 키를 얻을 수 있음
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)// 모든 트윗을 찾아 담고 반환
                completion(tweets)
            }
            // 이제 각 트윗과 연결된 사용자가 있음
            
        }
    }
    
    // 사용자가 작성한 모든 트윗에 대한 변경 내역을 실시간으로 검색하는 데 사용됩니다.
    func fatchTweets(forUser user: User, completion: @escaping([Tweet]) -> Void){
        var tweets = [Tweet]()
        
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            print(snapshot.key)
            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                guard let uid = dictionary["uid"] as? String else {return}
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)// 모든 트윗을 찾아 담고 반환
                    completion(tweets)
                }
            }
            
            // 프로필 이미지를 눌렀을때 user.uid에 해당하는것을 파이어베이스의가서 실제 값들을 건져오면 됨
        }
    }
    
}
