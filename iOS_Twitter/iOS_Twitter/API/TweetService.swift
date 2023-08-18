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
    
    // 별명 적용 : DatabaseCompletion
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
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
                
                // 작성한 사용자의 uid가 최종 부모 값이고 그 아래에 트윗 key를 저장
                // 따라서 궁극적으로 우리는 사용자가 어떤 트윗을 작성했는지 알아낼 수 있을 것입니다.
                // 이런것을 팬 아웃이라고 하며 : 서버 작업이 훨씬 줄어듬
            }
        case .reply(let tweet):
            // 답글일때는 기준 트윗 아이디 밑에 답글 트윗 을 생성
            REF_TWEET_REPLIES.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values, withCompletionBlock: completion)
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
            
            
            // 리팩토링 작업
            self.fetchTweet(with: tweetID) { tweet in
                tweets.append(tweet)// 모든 트윗을 찾아 담고 반환
                completion(tweets)
            }
            
//            REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
//                guard let dictionary = snapshot.value as? [String: Any] else {return}
//                guard let uid = dictionary["uid"] as? String else {return}
//
//                UserService.shared.fetchUser(uid: uid) { user in
//                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
//
//                }
//            }
            
            // 프로필 이미지를 눌렀을때 user.uid에 해당하는것을 파이어베이스의가서 실제 값들을 건져오면 됨
        }
    }
        
    
    
    // 알림탭에서, 상대방이 좋아요 누른 트윗으로 이동하는 메서드 : 위 코드를 복사
    func fetchTweet(with tweetID: String, completion: @escaping(Tweet) -> Void) {
        
        REF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
          var tweets = [Tweet]()

          REF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { snapshot in
              guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
              guard let uid = dictionary["uid"] as? String else { return }
              let tweetID = snapshot.key

              UserService.shared.fetchUser(uid: uid) { user in
                  let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                  tweets.append(tweet)
                  completion(tweets)
              }
          }
      }
    
    // 사용자 프로필에서 좋아요 누른 트윗을 가져오기 
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
           var tweets = [Tweet]()

           REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
               let tweetID = snapshot.key
               self.fetchTweet(with: tweetID) { likedTweet in
                   var tweet = likedTweet
                   tweet.didLike = true // 프로필에서 좋아요누른 트윗 보여줄때 빨간 하트 활성화 

                   tweets.append(tweet)
                   completion(tweets)
               }
           }


       }
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 좋아요 누르면 카운트 증감
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        REF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.didLike {
            // remove like data from firebase - unlike tweet
            //그래서 tweet-like 들어가서 트윗키찾고 좋아요 누른 유저 아이디찾고 지우기
            //user-likes들어가서 현재 사용자 ID를 찾은 다음 좋아요 취소한 트윗을 찾아 지우기
            REF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            // add like data to firebase - like tweet
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
            
        }
    }
    
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
         guard let uid = Auth.auth().currentUser?.uid else { return }

         REF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
             completion(snapshot.exists())
         }
     }
    
}
