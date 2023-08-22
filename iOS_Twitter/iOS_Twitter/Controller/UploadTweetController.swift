//
//  UploadTweetController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/20.
//

import UIKit
import ActiveLabel

class UploadTweetController: UIViewController {
    
    // MARK: -  Properties
    
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
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
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48/2
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private lazy var replyLabel: ActiveLabel = {
          let label = ActiveLabel()
          label.font = UIFont.systemFont(ofSize: 14)
          label.textColor = .lightGray
          label.mentionColor = .twitterBlue // 언급 색상 설정
          label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
          return label
      }()
    
    private let captionTextView = InputTextView() // 하위 클래스를 만들어 코드를 분리 시켰음 
    
    // MARK: - Lifecycle
    
    init(user: User, config: UploadTweetConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }   // 사용자 이미지를 가져오기 위해 불필요한 API 요청 할필요가 없음 이전화면에서 이미 사용자 데이터를 호출해 불러왔으니까 받기만 하면 되는 것임
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMentionHandler()

        switch config {
        case .tweet:
            print("DEBUG: Config is tweet")
        case .reply(let tweet):
            print("DEBUG: Replying to \(tweet.caption)")
        }
    }
    
    // MARK: - Selectors
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadTweet() {
        //print("업로드 트윗")
        guard let caption = captionTextView.text else {return}
        
        // 이미 config를 컨트롤러 만들때 초기화 하기 때문에 전달 할 수 있음
        TweetService.shared.uploadTweet(caption: caption, type: config) { (error, ref)in
            if let error = error {
                print("DEBUG: 트윗 업로드에 실패했습니다. error\(error.localizedDescription)")
                return
            }
            
            // 답장 알림 전송
            if case .reply(let tweet) = self.config {
                         NotificationService.shared.uploadNotification(type: .reply, tweet: tweet)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - API
    
    
    
    // MARK: - Helpers
    
    func configureUI(){
        view.backgroundColor = .white
        configureNavigationBar()
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        // stack.alignment = .leading
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        // 스택안에 요소 넣고 오토레이아웃 정의시 내부 알아서 조절해줌
        
        // 이미 MainTabController에서 FeedController로 이미지 전달하기 위해 user에 값이 있다는 것을 보장하기 때문에
        // 이렇게 코드를 작성하면 앱의 성능을 훨씬 더 좋게 만들어줌 불필요한 API 호출이 필요 없어서
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.placeholderLabel.text = viewModel.placeholderText
        
        replyLabel.isHidden = !viewModel.shouldShowReplyLabel
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
        
    }
    
    func configureNavigationBar(){
//        navigationController?.navigationBar.barTintColor = .white // Navigation bar의 배경색을 흰색으로 지정하는 코드입니다.
//        navigationController?.navigationBar.isTranslucent = false // Navigation Bar를 투명하지 않게 만드는 코드입니다.
//
        let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    func configureMentionHandler() {
        replyLabel.handleMentionTap { mention in // 언급 라벨을 누를시 해당 이름을 가져옴 
            print("DEBUG: Mentioned user is \(mention)")
        }
    }
}
