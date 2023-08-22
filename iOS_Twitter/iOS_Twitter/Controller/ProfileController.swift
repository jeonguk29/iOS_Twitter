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
    
    // 기본값을 .tweets로 지정해서 프로필 클릭시 Tweets이 첫화면임
    private var selectedFilter: ProfileFilterOptions = .tweets {
          didSet { collectionView.reloadData() }
    }
    
    private var tweets = [Tweet]()
    private var replies = [Tweet]()
    private var likedTweets = [Tweet]()

    // 프로필 화면에서 필터에따른 트윗을 보여주기 위해
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return tweets
        case .replies: return replies
        case .likes: return likedTweets
        }
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
        fetchLikedTweets()
        fetchReplies()
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
            self.collectionView.reloadData()
        }
    }
    
    // 좋아요 누른 트윗 가져오가
    func fetchLikedTweets() {
           TweetService.shared.fetchLikes(forUser: user) { tweets in
               self.likedTweets = tweets
               // selectedFilter 의 Didset 작동해서 화면 리로드 가능함 
           }
       }
    
    // 답장 트윗 가져오기
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets
            
//            self.replies.forEach { reply in
//                print("DEBUG: Replying to \(reply.replyingTo)")
//            }
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
        
        
        // 헤더에서 보여지는 트윗 많을때 스크롤 가능하게 높이를 조정
        guard let tabHeight = tabBarController?.tabBar.frame.height else {return}
        collectionView.contentInset.bottom = tabHeight
    }
}



// MARK: - UICollectionViewDataSource

extension ProfileController {
    //  프로필 헤더 대리자에는 어떤 필터가 선택되었는지 알려주는 함수가 필요합니다.
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = currentDataSource[indexPath.row]
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
    
    // 프로필에서 셀 누를때 메인과 동일하게 트윗으로 이동
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let tweet = currentDataSource[indexPath.row]
         let controller = TweetController(tweet: tweet)
         navigationController?.pushViewController(controller, animated: true)
     }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    //컬렉션 뷰의 헤더 만들기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 300.0 // 기본 높이
        
        if (user.bio ?? "") != "" { // 소개 글이 있을때 높이를 설정 
            height = 350.0
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = currentDataSource[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        
        // 답글이면 높이를 좀더 크게해서 간격을 일정하게 수정
        var height = viewModel.size(forWidth: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
}


// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func didSelect(filter: ProfileFilterOptions) {
        print("DEBUG: Did select filter \(filter.description) in profile controller..")
        self.selectedFilter = filter
    }
    
    
    // 커스텀 델리게이트로 팔로우 처리해주기 
    func handleEditProfileFollow(_ header: ProfileHeader) {

        //print("DEBUG: User is followed is \(user.isFollowed) before button tap ")
        
        if user.isCurrentUser {
            // 팔로우 못하게

            let controller = EditProfileController(user: user)
            controller.delegate = self
            
            let nav = UINavigationController(rootViewController: controller)

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .twitterBlue
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
            nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
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
                
                // 누군가를 팔로우하기 시작하면 알림을 보내야 합니다.
                NotificationService.shared.uploadNotification(toUser: self.user,
                                                              type: .follow)
                 
            }
        }

    }
 
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - EditProfileControllerDelegate
extension ProfileController: EditProfileControllerDelegate {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData() // 사용자 정보를 업데이트후 리로드
    }
}
