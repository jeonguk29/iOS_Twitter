//
//  ProfileController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/24.
//

import UIKit

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    
    // MARK: - properties
    
    private var user: User
    
    private var tweets = [Tweet]() {
        didSet {collectionView.reloadData()}
    }
    
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        //그리고 여기에서 Super.init를 호출할 때 이것은 컬렉션이기 때문에 이해하는 것이 매우 중요합니다.
        //컬렉션 뷰 컨트롤러도 초기화해야 합니다.
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
        fetchTweets()
        print("DEBUG: User is \(user.username)")
        checkIfUserIsFollowed()
        fetchUserStats()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true //네비게이션 바 숨기고 커스텀으로 만들기 위해
    }
    
    
    // MARK: - API
    
    func fetchTweets() {
        // FeedController에서 선택한 트윗셀의 user 정보를 전달 받기 때문에 바로 넘길 수 있음
        TweetService.shared.fatchTweets(forUser: user) { tweets in
            self.tweets = tweets
        }
    }
    
    func checkIfUserIsFollowed(){
        UserService.shared.checkIfUserIsFollowd(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            //print("DEBUG: User has \(stats.followers) followers")
            //print("DEBUG: User is following \(stats.following) people")
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never // 상태 표시줄 지우기
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //헤더 등록
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        
     
    }
}



// MARK: - UICollectionViewDataSource

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        return cell
    }
}


// MARK: - UICollectionViewDelegate

//재사용 가능한 헤더 추가
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.user = user
        header.delegate = self // 델리게이트 설정
        
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    //컬렉션 뷰의 헤더 만들기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 350)
    }
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}


// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    
    // 커스텀 델리게이트로 팔로우 처리해주기 
    func handleEditProfileFollow(_ header: ProfileHeader) {

        //print("DEBUG: User is followed is \(user.isFollowed) before button tap ")
        
        if user.isCurrentUser { // 현제 사용자 자기 자신 프로필 클릭시 아무일도 일어나지 않게 그냥 return
            // 팔로우 못하게 
            print("DEBUG : Show edit profile controller..")
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                //print("언팔로우 처리가 끝난후 돌아오는 곳 ")
                self.user.isFollowed = false
                print("DEBUG: User is followed is \(self.user.isFollowed) after button tap ")
                
                // UI 변경 팔로우에 따른 : API 호출 후에만 변경 됨
               // header.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.collectionView.reloadData()
            }
        } else {
            // 처음에 눌렀을때는 팔로우 하지 않은 false 상황이니까  여기가 눌릴것임
            UserService.shared.followUser(uid: user.uid) { (ref, err) in
                //print("팔로우 처리가 끝난후 돌아오는 곳 ")
                self.user.isFollowed = true
                print("DEBUG: User is followed is \(self.user.isFollowed) after button tap ")
                
                // UI 변경 팔로우에 따른
                //header.editProfileFollowButton.setTitle("Following", for: .normal)
                self.collectionView.reloadData()
            }
        }

    }
 
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}
