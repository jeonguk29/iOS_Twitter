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

let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")
let REF_TWEET_REPLIES = DB_REF.child("tweet-replies")

// likes
let REF_USER_LIKES = DB_REF.child("user-likes") // 유저가 좋아요 트윗을 파악
let REF_TWEET_LIKES = DB_REF.child("tweet-likes") // 트윗 잊장에서 누가 좋아요 눌렀는지 파악

// notifications
let REF_NOTIFICATIONS = DB_REF.child("notifications")

// tweet replies : 프로필에서 답글 남긴 트윗을 보여주기 위함 
let REF_USER_REPLIES = DB_REF.child("user-replies")

// mentions && hashtags
let REF_USER_USERNAMES = DB_REF.child("user-usernames")
