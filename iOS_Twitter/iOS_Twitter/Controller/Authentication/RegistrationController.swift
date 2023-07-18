//
//  RegistrationController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage: UIImage?
    
    
    
    private let PlusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAddProfilePhoto), for: .touchUpInside)
        return button
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
    
    private lazy var fullnameContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_mail_outline_white_2x-1")
        let view = Utilities().inputContaimerView(withImage: image, textField: fullnameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_lock_outline_white_2x")
        let view = Utilities().inputContaimerView(withImage: image, textField: usernameTextField)
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
    
    private let fullnameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Full Name")
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().textField(withPlaceholder: "UserName")
        return tf
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        // 첫번째 Don't have an account는 일반 폰트로 Sign Up은 Bold하게 만들 것임
        let button = Utilities().attributedButton("Already have an account?", " Log In")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    
    private let registrationButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handelRegistration), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Selectors
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleAddProfilePhoto(){
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handelRegistration(){
        guard let profileImage = profileImage else {
            print("DEBUG: 프로필 이미지를 선택해주세요")
            return
        }
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.shared.registerUser(credentials: credentials){ (error, ref) in
//            print("사용자가 성공적으로 가입되었습니다.")
//            print("사용자의 인터페이스를 업데이트 할 부분입니다.")
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
    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(PlusPhotoButton)
        PlusPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        PlusPhotoButton.setDimensions(width: 128, height: 128)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullnameContainerView, usernameContainerView, registrationButton])
        stack.axis = .vertical // 세로축 정렬
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: PlusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32,
        paddingLeft: 32, paddingRight: 32)
        
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left:view.leftAnchor,
                            bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            right: view.rightAnchor, paddingLeft: 40,
                            paddingRight: 40)
    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 이 기능을 사용하면 선택한 미디어 항목이 사진이든 동영상이든 액세스할 수 있습니다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이 정보는 당신이 어떤 유형을 선택했는지 알아야 하기 때문에 사전입니다.
        // 원본이든 편집된 이미지든 영화든 영상이든 뭐든 그래서 우리는 이편집 이미지 키를 사용하여 해당 사전에서 값을 가져옵니다.
        guard let profileImage = info[.editedImage] as? UIImage else {return}
        self.profileImage = profileImage
        
        // 둥글게 설정
        PlusPhotoButton.layer.cornerRadius = 128 / 2
        PlusPhotoButton.layer.masksToBounds = true
        
        // 가로 세로 비율 맞추기 : 이미지가 포함된 프레임에 맞게 이미지의 크기를 조정합니다.
        PlusPhotoButton.imageView?.contentMode = .scaleAspectFill
        PlusPhotoButton.imageView?.clipsToBounds = true // 프레임 범위를 벗어나지 않도록 설정
        
        // 테두리 추가
        PlusPhotoButton.layer.borderColor = UIColor.white.cgColor // 보더 색상 설정시 .cgColor를 붙여줘야함
        PlusPhotoButton.layer.borderWidth = 3
        
        // 선택한 원본 이미지를 이미지 버튼에 삽입
        self.PlusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil) // 해당 코드가 있어야 이미지 선택후 빠져나올수 있음
    
    }
}
