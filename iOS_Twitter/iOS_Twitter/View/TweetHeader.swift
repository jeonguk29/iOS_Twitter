//
//  TweetHeader.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/05.
//

import UIKit

class TweetHeader: UICollectionReusableView {
    
    
    // MARK: - Properties
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemPurple
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
