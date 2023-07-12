//
//  MainTabController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit

class MainTabController: UITabBarController {

    
    // MARK: - Properties
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        tabBar.backgroundColor = .systemGray5
    }
    

    
    // MARK: - Helpers
    
    func configureViewControllers() {
        let feed = FeedController()
        // UINavigationController 가져와서 그안에 feed 를 붙여줌
        let nav1 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        
        let explore = ExploreController()
        let nav2 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: notifications)
        
        
        let conversations = ConversationsController()
        let nav4 = templeteNavigationController(image: UIImage(named: "home_unselected"), rootViewController: conversations)
        
        
        
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
