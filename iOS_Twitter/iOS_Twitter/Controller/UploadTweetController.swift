//
//  UploadTweetController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/20.
//

import UIKit

class UploadTweetController: UIViewController {
    
    // MARK: -  Properties
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        //addTarget을 설정할 경우 lazy var로 만들어야함 
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadTweet() {
        print("업로드 트윗")
    }
    
    
    // MARK: - API
    
    
    
    // MARK: - Helpers
    
    func configureUI(){
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white // Navigation bar의 배경색을 흰색으로 지정하는 코드입니다.
        navigationController?.navigationBar.isTranslucent = false // Navigation Bar를 투명하지 않게 만드는 코드입니다.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
}
