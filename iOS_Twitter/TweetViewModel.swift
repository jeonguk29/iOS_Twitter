//
//  TweetViewModel.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/24.
//

import UIKit

// 뷰 모델은 모델 즉 TweetCell의 부담을 덜어주는 용도로 사용하는 것임
// ex 계산속성 같은 몇분전 트윗인지 등등
struct TweetViewModel {
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL?{
        return user.profileImageUrl
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        //이것은 두 날짜 사이의 시차를 기반으로 형식이 지정된 문자열을 반환합니다.
        return formatter.string(from: tweet.timestamp, to: now) ?? "2m"
    }
    
    // 트윗 셀에서 작성하는 대신 원하는 효과를 여기 뷰모델에서 얻을수 있음 큐 클래스를 깨끗하게 유지할 수 있음
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: "@\(user.username)",
                    attributes: [.font : UIFont.boldSystemFont(ofSize: 14),
                                            .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " ・ \(timestamp)",
                    attributes: [.font : UIFont.boldSystemFont(ofSize: 14),
                                            .foregroundColor: UIColor.lightGray]))
        

        return title
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
}