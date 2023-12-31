//
//  TweetController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/04.
//

import UIKit

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "TweetHeader"

class TweetController: UICollectionViewController {
    //CollectionView로 구현한 이유는 이 트윗에 대한 트윗 답글을 표시하기 위함임
    
    
    // MARK: - Properties
    
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        // 현재 사용자가 아닌 경우 해당 사용자를 팔로우하고 있는지 확인하고 초기화 해야함
        //self.actionSheetLauncher = ActionSheetLauncher(user: tweet.user)
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
        //        print("DEBUG: Tweet caption is \(tweet.caption)")
    }
    
    // 프로필에서 트윗 누를때 네비게이션 올라오게 구현
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchReplies() {
        print("DEBUG: Tweet ID is \(tweet.tweetID)")
        
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies // 답글 트윗 배열 받기
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView(){
        collectionView.backgroundColor = .white
        
        // 트윗 헤더 등록하기
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //헤더 등록
        collectionView.register(TweetHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        
        
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
    
}


// MARK: - UICollectionViewDataSource

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

//재사용 가능한 헤더 추가
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TweetHeader
        
        header.tweet = tweet
        header.delegate = self
        return header
    }
}

// MARK: -  UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {
    //컬렉션 뷰의 헤더 만들기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - TweetHeaderDelegate
// 사용자 작업 시트를 위한 프로토콜을 채택하여 구현
extension TweetController: TweetHeaderDelegate {
    
    // 헤더에서 언급 사용자 클릭시 처리 구현
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(WithUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showActionSheet() {
        // 현재 사용자가 아닌 경우 해당 사용자를 팔로우하고 있는지 확인하는 부분
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            UserService.shared.checkIfUserIsFollowd(uid: tweet.user.uid) { isFollowed in
                var user = self.tweet.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate
extension TweetController: ActionSheetLauncherDelegate {
    
    // 트윗 컨트롤러에서 해당 선택 항목에 대한 작업을 처리
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            print("DEBUG: Follow \(user.username)")
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                print("DEBUG: Did Follow \(user.username)")
            }
        case .unfollow(let user):
            print("DEBUG: UnFollow \(user.username)")
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                print("DEBUG: Did UnFollow \(user.username)")
            }
        case .report:
            print("DEBUG: Report tweet")
        case .delete:
            print("DEBUG: Delete tweet..")
        }
    }
}

