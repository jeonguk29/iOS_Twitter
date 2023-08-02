//
//  UserService.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/18.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

typealias DatabaseCompletion = ((Error? , DatabaseReference) -> Void)

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        //print("DEBUG: 현재 사용자 정보를 가져온다.")
       // guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //💁 전달받는 uid에 따른 사용자를 가져오게 수정함
        // 데이터베이스에서 이 정보를 한번만 가져오려고 함, 단일 이벤트를 관찰
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
           
            //print("DEBUG: Snapshot \(snapshot)")
            guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
            //print("DEBUG: Dictionary is \(dictionary)")
            
            // 두개는 미우 비슷하지만 우리가 이것을 어떨게 사용하게 될지에 따라 큰 차이를 만듬
            // 스냅샷은 해당 스냅샷에 대한 키도 나옴 Snapshot Snap (NO6TkcQJs3MFpMOXLNnIRJ5Br8S2)
            // 해당 스냅샷의 값들을 딕셔너리 타입으로 케스팅하여 편하게 사용할 것임
            guard let username = dictionary["username"] as? String else {return}
            //print("DEBUG: 현제 사용자의 이름 \(username)")
            
            let user = User(uid: uid, dictionary: dictionary)
            //print("DEBUG: 현제 사용자의 name \(user.username)")
            //print("DEBUG: 현제 사용자의 fullname \(user.fullname)")
            completion(user)
        }
    }
    
    // 사용자 검색을 위해 사용할 부분
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        REF_USERS.observe(.childAdded) { snapshot in
            /*
             print(snapshot)
             Snap (NO6TkcQJs3MFpMOXLNnIRJ5Br8S2) {
                 email = "b@b.com";
                 fullname = Qwer;
                 profileImageUrl = "https://firebasestorage.googleapis.com:443/v0/b/twittertutorial-1c5cf.appspot.com/o/profile_images%2F0D15AC49-D2F0-49CF-A4B1-2D6D3510E42B?alt=media&token=724ade5c-3a80-4824-b28e-a8c4c6392322";
                 username = Qwer;
             }
             */
            
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            print(user.username)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping(DatabaseCompletion)){
        // 사용자 A가 B를 팔로우 하면 B사용자 밑에 A, C ... 등등을 연결하고
        // 사용자 A가 누구를 팔로우 하는지 A밑에 B를 추가 해서 각각 관리하는 구조임
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
    
        REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { (err, ref) in
            REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    
        
        print("DEBUG: Current uid \(currentUid) started following \(uid)")
        print("DEBUG: Uid \(uid) gained \(currentUid) as a follower")
    }
    
    func unfollowUser(uid: String, completion: @escaping(DatabaseCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue() { (err, ref) in
            // 팔로잉을 먼저 제거하고 팔로우를 제거하기 
            REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    
    }
}
