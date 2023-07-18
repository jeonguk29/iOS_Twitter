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

class MainTabController: UITabBarController {

    
    // MARK: - Properties
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
  //      logUserOut()
        view.backgroundColor = .twitterBlue // 앱 로드시 검정화면 파란색으로 맞춰주기 위함
        authenticateUserAndConfigureUI()
      
    }
    
    
    // MARK: - API
    func fetchUser(){
        // 파이어베이스에서 사용자 데이터 가져오기
        UserService.shared.fetchUser()
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
    
    func logUserOut(){ // 로그인 확인을 하기 위한 임시 함수
        do {
            try Auth.auth().signOut()
            print("DEBUG: 유저가 로그아웃 했습니다.")
        }catch let error {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selectors
    @objc func actionButtonTapped(){
        print(1234)
    }

    
    // MARK: - Helpers
    func configureUI() {
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
        let feed = FeedController()
        // UINavigationController 가져와서 그안에 feed 를 붙여줌
        let nav1 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        
        let explore = ExploreController()
        let nav2 = templeteNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: notifications)
        
        
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
