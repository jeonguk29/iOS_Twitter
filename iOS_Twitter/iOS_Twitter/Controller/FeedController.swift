//
//  FeedController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController{
    // MARK: - Properties
    
    
    // 아래 이미지를 보여주는 코드가 실행되기 전에 해당 유저 데이터가 없을 수도 있음
    // 따라서 기본적으로 프로필 이미지를 설정하기 전에 사용자가 설정되었는지 확인해야 합니다.
    var user: User? { // 변경이 일어나면 아래 사용자 이미지 화면에 출력
        didSet {
            configureLeftBarButton() // 해당 함수가 호출 될때는 사용자가 존재한다는 것을 알수 있음
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {collectionView.reloadData()}
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        // ProfileHeader 에서 뒤로가기할때 navigationController 데리자가 수행하는데 그때
        // 프로필보기 쪽에서 헤더를 보이지 않게 만들어서 돌아올때 설정 값이 남아있을수 있음 그래서 해당 속성을 추가
    }
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    // MARK: - API
    func fetchTweets(){
        collectionView.refreshControl?.beginRefreshing() // 새로고침 컨트롤러 추가
        TweetService.shared.fatchTweets { tweets in
            self.tweets = tweets
            self.checkIfUserLikedTweets()
            // 날짜 순으로 트윗 정렬
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            // 아래 코드를 축약 한 것임
            //            self.tweets = tweets.sorted(by: {(tweet1, tweet2) -> Bool in
            //                return tweet1.timestamp < tweet2.timestamp
            //            })
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedTweets() {
        // 2. 실제 데이터베이스에 저장된 정보로 모든 트윗을 돌리면서 확인하고 화면에 적용하기 위한 작업
        
        // 현제 피드에서 언팔로우를 하고 다시 사용자 검색 화면에서 팔로우 눌렀을때 해당 좋아요 체크부분에서 오류가 나는 것을 해결
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                // 두 인덱스 개수가 맞지 않아서 아래 코드를 작성한 것임
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        //  재사용 셀에 재사용 식별자 등록
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
        
        // 피드 새로고침 가능하게 새로고침시 트윗 다시 보여주기 : 팔로우 취소한 사람 트윗에 대하여, 팔로우 했을때는 새 노드가 추가될 때마다 감시 대기하는 데이터베이스 구조에 수신기가 있기 때문에 바로바로 적용 됨 피드에
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton(){
        guard let user = user else {return}
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }

}


// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("DEBUG: Tweet count at time of collectionView function call is \(tweets.count)")
        /*
         private var tweets = [Tweet]() 으로만 코드 작성을 했을때
         현제 0이 출력되는데 뷰가 로드되지마자 이함수가 호출 되기 때문임 뷰가 로드 될때는 tweets 배열이 빈 배열임
         따라서 이 데이터 가져오기를 완료하고 결과로 이 트윗 배열을 실제로 설정하는 데 시간이 걸립니다.
         그래서 화면에 보이는게 없지만 데이터를 가져와서 didSet을 통해 변경사항이 있을경우 리로드를하면 정상적으로 출력이 가능함
         리로드시 확장으로 구현한 함수들은 다시 한번씩 호출 됨
         +
         이제 우리의 트윗 수는 2개가 될 것입니다.
         따라서 두 개의 셀로 컬렉션 뷰를 다시 로드할 것입니다.
         */
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        //print("DEBUGP: indexPath is \(indexPath.row)")
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    // 셀하나 선택시 일어나는 작업을 설정하는 메서드
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //동적 셀 크기 조정
        let tweet = tweets[indexPath.row]
        let viewModel = TweetViewModel(tweet: tweet)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72) // height + 72 이유 : 캡션과 아래 4가지 버튼들 사이 여백을 주기 위함 
    }
}



// MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(WithUsername: username) { user in
            print(user.username)
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        print("DEBUG: Handle like tapped..")
        
        guard var tweet = cell.tweet else { return }
//        cell.tweet?.didLike.toggle()
//        print("DEBUG: Tweet is liked is \(cell.tweet?.didLike)")
        TweetService.shared.likeTweet(tweet: tweet) { (err, ref) in
            cell.tweet?.didLike.toggle()
            // 셀에 있는 개체를 실제로 업데이트 하는 부분 API호출시 서버먼저 처리하고 여기서 화면 처리를 하는 것임
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes // 이코드 실행시 Cell의 didSet이 수행됨
            //트윗을 설정하든, 트윗안에 사용자를 재설정하든, 트윗의 좋아요 수를 재설정하든, didSet이 호출되는 것임
            //그런다음 configure()이 호출 되고 뷰모델러 트윗을 넘겨준 다음 화면에 정상적인 값을 표시할 수 있음
            
            // 트윗이 좋아요인 경우에만 업로드 알림
            guard cell.tweet?.didLike == true else { return }
            
            NotificationService.shared.uploadNotification(toUser: tweet.user,
                                                                      type: .like,
                                                                      tweetID: tweet.tweetID)
        }
        
    }
    
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        // 이미지 표시 등을 위해 유저 정보를 전달, .reply 인것을 알려주기
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handelProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }// 해당 출력이 나온다면 트윗 셀에서 컨트롤러로 작업을 성공적으로 위임한것임
    
}
