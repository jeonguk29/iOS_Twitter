//
//  ProfileHeaderViewModel.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/25.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

// 헤더 ProfileView에 부담을 주지 않기 위해 동적 기능을 처리 하는 부분을 구현
// 실제 유저의 데이터를 받아와서 이쪽에서 처리하고 뷰로 전달 할것임(ProfileHeader)
struct ProfileHeaderViewModel {
    private let user: User
    
     let usernameText : String
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: 0, text: "followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: 2, text: "following")
    }
    
    var actionButtonTitle: String {
        // 자신의 프로필 눌렀을때는 프로필 수정 버튼으로 표시
        // 아니라면 상대방 팔로우 버튼으로 표시
        // 이를 위해 User모델의 속성을 하나 추가했음
        
        if user.isCurrentUser {
            return "Edit Profile"
        }else {
            return "Follow"
        }
    }
    
    init(user: User) {
        self.user = user
        self.usernameText = "@" + user.username
    }
    
    // fileprivate 비공계로 설정, 도움이 함수일 뿐임
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
