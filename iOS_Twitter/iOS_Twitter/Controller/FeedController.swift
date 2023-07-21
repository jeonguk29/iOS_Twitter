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
    
    
    // MARK: - API
    func fetchTweets(){
        TweetService.shared.fatchTweets { tweets in
            self.tweets = tweets
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
        
        print("DEBUGP: indexPath is \(indexPath.row)")
        cell.tweet = tweets[indexPath.row]
        
        return cell 
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    
    // 각 셀의 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
