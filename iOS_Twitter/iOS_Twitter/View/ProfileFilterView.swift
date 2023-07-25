//
//  ProfileFilterView.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/24.
//

import UIKit


private let reuseIdentifier = "ProfileFilterCell"

protocol ProfileFilterViewDelegate: class {
    func filterView(_ view: ProfileFilterView, didSelect indexPath: IndexPath)
}

class ProfileFilterView: UIView {


    // MARK: - Properties

    weak var delegate: ProfileFilterViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        addSubview(collectionView)
        collectionView.addConstraintsToFillView(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: - UICollectionViewDataSource

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProfileFilterCell
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension ProfileFilterView: UICollectionViewDelegate {
    
    // 각 아이템을 선택할때마다 호출 되는 함수임
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filterView(self, didSelect: indexPath) // 이제 우리는 이 프로토콜을 준수해야 하며 프로필 헤더 내부에서 그렇게 할 것임
        
    }
}



// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    
    // 각각의 셀 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //frame의 너비를 3등분한 너비
        return CGSize(width: frame.width / 3, height: frame.height)
    }
    
    // 섹션과 섹션사이의 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

