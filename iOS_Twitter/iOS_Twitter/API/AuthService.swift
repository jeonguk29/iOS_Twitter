//
//  AuthService.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/18.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func registerUser(credentials : AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void){
        let email = credentials.email
        let password = credentials.password
        let fullname = credentials.fullname
        let username = credentials.username
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else {return}
        
        let filename = NSUUID().uuidString // filename은 유일한 값을 생성하여 이미지를 저장할 때 파일 이름을 만드는 데 사용됩니다.
        let storageRef = STORAGE_PROFILE_IMAGE.child(filename)
       
        storageRef.putData(imageData) { (mata, error) in
            // 다운로드 URL를 받아야함
            storageRef.downloadURL { (url, error)in
                guard let profileImageUrl = url?.absoluteString else {return}
                
                // 파이어베이스의 사용자를 생성
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    // iOS에서 completion 매개변수는 비동기 작업이 완료된 후 실행될 코드 블럭을 지정하는 매개변수임
                    // 일반적으로 비동기 작업이 완료된 후 실행할 코드를 전달하기 위해 사용 ex API 호출
                    if let error = error {
                        print("DEBUG:  Error is \(error.localizedDescription)")
                        return
                    }
                    
                    print("성공적으로 사용자 등록")
                    // 성공시 사용자에게 할당되는 고유의 uid를 가져옴, 데이터베이스에 저장할때 사용자 고유의 데이터를 관리하기 위함임
                    guard let uid = result?.user.uid else {return}
                    
                    let values = ["email" : email,
                                  "username" : username,
                                  "fullname" : fullname,
                                  "profileImageUrl" : profileImageUrl]
                    
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    
                }
            }
            
            
        }
    }
}
