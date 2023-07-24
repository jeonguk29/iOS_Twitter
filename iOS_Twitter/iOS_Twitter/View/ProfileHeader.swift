//
//  ProfileHeader.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/24.
//

import UIKit

// 컬렉션뷰의 재사용 가능한 뷰로 만듬
class ProfileHeader: UICollectionReusableView {
    
    // MARK: - properties
    
    
    // MARK: - Lifecycle
    
    // 왜 뷰디드로드가 아니지?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor =  .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
