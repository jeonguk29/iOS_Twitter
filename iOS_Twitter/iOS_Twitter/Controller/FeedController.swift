//
//  FeedController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit

class FeedController: UIViewController{
    // MARK: - Properties
    
    var user: User? { // 변경이 일어나면 아래 메세지를 출력
        didSet {
            print("DEBUG: Did set user in FeedController..")
        }
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .twitterBlue
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }

}
