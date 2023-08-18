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
    
    
    // MARK: - Properties
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
    
    // 실제 데이터 뿌려주기
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ・ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var retweetsAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.retweetCount, text: "Retweets")
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: tweet.likes, text: "Likes")
    }
    
    // 트윗 셀에서 작성하는 대신 원하는 효과를 여기 뷰모델에서 얻을수 있음 큐 클래스를 깨끗하게 유지할 수 있음
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user.username)",
                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14),
                                                     .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " ・ \(timestamp)",
                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14),
                                                     .foregroundColor: UIColor.lightGray]))
        
        
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)! // we know these images exist
    }
    
    // 답글인지 여부에 따라 답글 라벨을 표시 
    var shouldHideReplyLabel: Bool {
         return !tweet.isReply
     }

     var replyText: String? {
         guard let replyingToUsername = tweet.replyingTo else { return nil }
         return "→ replying to @\(replyingToUsername)"
     }
    
    // MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize:14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize:14),
                                                                                   NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedTitle
    }
    
    
    // MARK: - Helpers
    
    //동적 셀 크기 조정
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = tweet.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
