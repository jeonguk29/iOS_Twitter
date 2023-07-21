//
//  TweetCell.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/21.
//

import UIKit

class TweetCell:UICollectionViewCell {
    override init(frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
