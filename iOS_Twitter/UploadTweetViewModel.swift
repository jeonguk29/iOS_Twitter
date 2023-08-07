//
//  UploadTweetViewModel.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/07.
//

import UIKit

enum UploadTweetConfiguration { // 트윗인지, 답글인지 구분하기 위한 enum 타입 
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    let actionButtonTitle: String
    let placeholderText: String
    let shouldShowReplyLabel: Bool // 트윗 남기는건지, 답글 남기는건지 판독하기 위한
    var replyText: String?

    init(config: UploadTweetConfiguration) {
        switch config {
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening?"
            shouldShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.user.username)"
        }
    }
}
