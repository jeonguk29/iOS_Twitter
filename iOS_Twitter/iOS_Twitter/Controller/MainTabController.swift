//
//  MainTabController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase


enum ActionButtonConfiguration { // 모든 탭에 올라와 있는 액션버튼의 형태를 변경하기 위한 enum 타입
    case tweet
    case message
}

class MainTabController: UITabBarController {

    
    // MARK: - Properties
    
    private var buttonConfig: ActionButtonConfiguration = .tweet // 기본은 tweet 형태
    
    
    // 사용자 설정시 즉 사용자를 불러오면 아래 블럭이 실행됨 : 사용자가 실제로 값을 가지고 있고 값이 설정되면 실행된다는것을 보장
    var user: User? { // 변경이 일어나면 아래 메세지를 출력
        didSet {
            print("DEBUG: Did set user in main tab..")
            guard let nav = viewControllers?[0] as? UINavigationController else {return}
            guard let feed = nav.viewControllers.first as? FeedController else {return}
            feed.user = user
            
            /* 아래서 뷰컨들을 설정해줬음
             // UITabBarController 에서 제공하는 속성임 안에 배열 형태로 뷰를 넣어주면 됨
             viewControllers = [nav1, nav2, nav3, nav4] 0,1,2,3
             0번째 FeedController 위에 네비게이션 컨트롤러를 올렸었음
             그 네비게이션의 첫번째 내장 컨틀로러가 FeedController임 
             */
            
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        //button.backgroundColor = .blue
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        // 버튼 액션 추가
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //logUserOut()
        view.backgroundColor = .twitterBlue // 앱 로드시 검정화면 파란색으로 맞춰주기 위함
        authenticateUserAndConfigureUI()
      
    }
    
    
    // MARK: - API
    func fetchUser(){
        // 파이어베이스에서 사용자 데이터 가져오기
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            //print("DEBUG: 사용자가 로그인 하지 않았습니다.")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }else {
            //print("DEBUG: 사용자가 로그인 했습니다.")
            configureViewControllers() // 로그인 했으면 탭바 보여주기
            configureUI()
            fetchUser()
        }
    }
   
    
    // MARK: - Selectors
    @objc func actionButtonTapped(){
        
        let controller: UIViewController
        
        switch buttonConfig { // 상태에 따른 각 액션을 다르게 처리할 컨트롤러를 호출 
        case .message:
            controller = SearchController(config: .messages)
        case .tweet:
            guard let user = user else { return }
            controller = UploadTweetController(user: user, config: .tweet)
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

    
    // MARK: - Helpers
    func configureUI() {
        self.delegate = self
        
        
        view.addSubview(actionButton)
//        actionButton.translatesAutoresizingMaskIntoConstraints = false
//        actionButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
//        actionButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
//        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64).isActive = true
//        actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true

        // ⭐️ 해당 한줄의 코드가 위 코드를 대체함
        // safeAreaLayoutGuide는 safeArea를 말함
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        
        actionButton.layer.cornerRadius = 56/2 // 높이 나누기 2 하면 원형 모양이 됨
                
        
    }
    
    
    func configureViewControllers() {
        // FeedController를 UICollectionViewController을 상속 받게 수정했기 때문에 아래 프로퍼티를 추가해줘야함
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        // UINavigationController 가져와서 그안에 feed 를 붙여줌
        let nav1 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        
        let explore = SearchController(config: .userSearch)
        let nav2 = templeteNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templeteNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)
        
        
        let conversations = ConversationsController()
        let nav4 = templeteNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        
        
        // UITabBarController 에서 제공하는 속성임 안에 배열 형태로 뷰를 넣어주면 됨
        viewControllers = [nav1, nav2, nav3, nav4]
        
    }
    
    
    func templeteNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
        return nav
    }
    
    // 현제 탭바안에 각 뷰컨트롤러들을 연결 하였고 각 뷰컨트롤러마다 네비게이션컨틀롤러를
    // 연결하고 설정을 해주었음 네비게이션을 만들때마다 코드를 반복하지 않기 위해 함수를 만들어줌
}

extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        // 각 탭을 선택할때마다 첫번째 인덱스가 나와서 0,1,2,3을 받을 수 있음
        
        let image = index == 3 ? UIImage(named: "mail") : UIImage(named: "new_tweet")
        actionButton.setImage(image, for: .normal)
        buttonConfig = index == 3 ? .message : .tweet // 상태도 바꿔주기
    }
}
