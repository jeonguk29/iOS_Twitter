//
//  Constants.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/17.
//

import FirebaseDatabase
import FirebaseStorage

// 파이어베이스에 빠르게 접근하기 위한 상수들을 정의, 생성
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")//해당 사용자 구조에 액세스하려고 할 때마다 참조가 될 것입니다.

let STORAGE_REF = Storage.storage().reference() // 사용자 프로필 이미지는 FirebaseFirestore에 저장할것임
let STORAGE_PROFILE_IMAGE = STORAGE_REF.child("profile_images")

let REF_TWEETS = DB_REF.child("tweets")
let REF_USER_TWEETS = DB_REF.child("user-tweets")

