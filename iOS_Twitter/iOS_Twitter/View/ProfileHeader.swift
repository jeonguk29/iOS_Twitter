//
//  ProfileHeader.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/24.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func handleDismissal()
    func handleEditProfileFollow(_ header: ProfileHeader) // 팔로우를 처리할 프로토콜 메서드 만들기
    func didSelect(filter: ProfileFilterOptions) // 프로필 필터가 옵션이 될 수 있는 선택이 될 것입니다.
    // 리팩토링 이후 하위 보기, 즉 필터 표시줄에서 헤더로 작업을 다시 위임합니다.그런 다음 해당 작업을 헤더에서 컨트롤러로 다시 위임해야 합니다.
}

// 컬렉션뷰의 재사용 가능한 뷰로 만듬
class ProfileHeader: UICollectionReusableView {
    
    // MARK: - properties
    
    var user: User? {
        didSet { configure()}
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private let filterBar = ProfileFilterView() // 3개의 필터 셀을 가지고 있는
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    // #imageLiteral() 이미지 리터럴
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_white_24dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        // 흰색 테두리
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
 
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3 // 최대 3줄까지만
        label.text = "hihihihihi is jjk App"
        return label
    }()
    
   
    
    private let followingLabel: UILabel = {
        let label = UILabel()
       // label.text = "0 Following"
        
        // 사용자의 팔로워를 볼 수 있도록 탭 제스처 인식기를 추가하고 있습니다.
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
     //   label.text = "2 Followers"
        
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    // 왜 뷰디드로드가 아니지?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        filterBar.delegate = self
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(profileImageView)
        
        // 바텀에 고정한후 -라서 위로 24올라가는 것임
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor, paddingTop: -24, paddingLeft: 8)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor,
                                       right: rightAnchor, paddingTop: 12,
                                       paddingRight: 12)
        
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                              usernameLabel,
                                                              bioLabel])
        userDetailsStack.axis = .vertical // 세로축
        userDetailsStack.distribution = .fillProportionally // 사용가능한 항목을 채우기
        userDetailsStack.spacing = 4 // 각 아이템 간격
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor,
                                right: rightAnchor, paddingTop: 8, paddingLeft: 12,
                                paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal // 수직
        followStack.spacing = 8         // 간격
        followStack.distribution = .fillEqually // 나눠서 가득 채우기
        
        addSubview(followStack)
        followStack.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleDismissal() {
        // 여기는 헤더이며 UICollectionReusableView를 상속 받은 곳임 컨트롤러와 다르게 dismiss 나오지 않음
        // 그래서 커스텀 델리게이트를 만들어 헤당 컨트롤러에게 작업을 위임하는 프로토콜을 만들것임
        delegate?.handleDismissal()
    }
    
    @objc func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc func handleFollowersTapped() {
        
    }
    
    @objc func handleFollowingTapped() {
        
    }
    
    
    // MARK: - Helpers
    
    func configure() {
        //여기에서 ViewModel을 구성할 것입니다.
        //사용자를 전달해야 합니다.
        
        
        guard let user = user else {return}
        
        print("DEBUG: Did set called for user in profile header..")
        
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
            
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        followingLabel.attributedText = viewModel.followingString
        followersLabel.attributedText = viewModel.followersString
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
    }

}


// MARK: - ProfileFilterViewDelegate

extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(_ view: ProfileFilterView, didSelect index: Int) {
        guard let filter = ProfileFilterOptions(rawValue: index) else { return }
        
        print("DEBUG: delegate action from header to controller with filter \(filter.description)")
        delegate?.didSelect(filter: filter)
    }
}
