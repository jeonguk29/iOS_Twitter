//
//  LoginController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit // contentMode 속성은 이미지 뷰에 표시될 이미지의 크기 조정 및 배치 방법을 결정합니다. contentMode 속성을 .scaleAspectFit으로 설정하면 이미지를 가능한 크게 표시하면서도 이미지 뷰 영역 바깥으로 넘치지 않도록 이미지의 비율을 유지합니다.
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "TwitterLogo")
        // #imageLiteral() 이미지 리터럴

        return iv
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_mail_outline_white_2x-1")
        let view = Utilities().inputContaimerView(withImage: image, textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_lock_outline_white_2x")
        let view = Utilities().inputContaimerView(withImage: image, textField: passwordTextField)
        return view
    }()
    
    
    private let emailTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handelLogin), for: .touchUpInside)
        return button
    }()
    
    
    private let dontHaveAccountButton: UIButton = {
        // 첫번째 Don't have an account는 일반 폰트로 Sign Up은 Bold하게 만들 것임
        let button = Utilities().attributedButton("Don't have an account?", " Sign Up")
        button.addTarget(self, action: #selector(handleShowsignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Selectors
    @objc func handelLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG : 로그인 에러 in \(error.localizedDescription)")
                return
            }
            //print("DEBUG : 로그인 성공")
            
            // 다시 메인화면 보여주기
            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
                return }
            
            guard let tab = window.rootViewController as? MainTabController else {return}
            
            tab.authenticateUserAndConfigureUI()
            
            self.dismiss(animated: true, completion: nil) // 현제 present되어있는 로그인 컨트롤러를 닫고
            /*
             이 코드는 사용자 인증(authentication)을 하고, UI(user interface)를 설정합니다. 먼저, guard let 키워드를 사용해서 현재 앱에서 가장 위에 올려져있는 화면, 즉 키 윈도우(key window)를 찾습니다. 그 다음에는, 이 화면에서 rootViewController로 설정된 컨트롤러(MainTabController)가 있는지 확인합니다. 만약 없다면, 해당 메서드는 실행되지 않고 종료됩니다. 하지만 MainTabController가 발견된다면, 해당 컨트롤러의 메서드인 authenticateUserAndConfigureUI()를 실행합니다. 이 메서드는 사용자 인증 과정을 거치고, UI를 설정합니다. 마지막으로, dismiss 메서드를 호출하여 현재 present되어 있는 로그인 컨트롤러를 닫습니다. 이러한 과정을 통해 사용자는 로그인 컨트롤러를 명확하게 닫고, MainTabController로 이동할 수 있습니다.
             */
        }
    }
    
    @objc func handleShowsignUp(){
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black // 해당 코드는 상태표시줄을 하얀색으로 만들어줌 ex 시간, 와이파이, 베터리 등
        navigationController?.navigationBar.isHidden = true // 네비게이션바 감추기
        
        // 이미지를 X축 중심에 있고, 화면 상단의 safeArea에 고정 시키기
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        // 오토레아웃 편하게 사용하기위해 만든 함수 중앙정렬, 어디기준으로 할건지, 기준에서 어디만큼 위치할건지 paddingTop: 0 이 기분값임
        logoImageView.setDimensions(width: 150, height: 150)
        // UIView 프로토콜에 추가된 확장 함수(extension function)로, 주어진 view의 너비와 높이를 변경합니다.
        
        // 스택뷰로 두게의 컨테이너를 묶어주기
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical // 세로축 정렬
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        // 두개의 컨테이너의 각각의 50의 높이를 주었기 때문에 스택은 알아서 높이를 잡을 것임
        // 오토레이 아웃의 기본은 높이,너비, 제약조건임
        view.addSubview(stack)
        // 너비를 따로 지정해주지 않아서 기본적으로 스택은 뷰가 가진 너비 왼쪽, 오른쪽 오토레이아웃 만큼 크기를 갖게 됨
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
        paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left:view.leftAnchor,
                                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                     right: view.rightAnchor, paddingLeft: 40,
                                     paddingRight: 40)
    }
    
    
}
