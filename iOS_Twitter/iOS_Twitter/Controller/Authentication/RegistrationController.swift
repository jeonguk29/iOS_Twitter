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
        
        // 사용자 이미지를 저장할때 파일이름을 우리가 생성하고 전달 해야함 
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else {return}
        let filename = NSUUID().uuidString // 파일 이름 직접 생성하기 위함
        let storageRef = STORAGE_PROFILE_IMAGE.child(filename)
       
        storageRef.putData(imageData) { (mata, error) in
            // 다운로드 URL를 받아야함
            storageRef.downloadURL { (url, error)in
                guard let profileImageUrl = url?.absoluteString else {return}
                
                // 파이어베이스의 사용자를 생성
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    // iOS에서 completion 매개변수는 비동기 작업이 완료된 후 실행될 코드 블럭을 지정하는 매개변수임
                    // 일반적으로 비동기 작업이 완료된 후 실행할 코드를 전달하기 위해 사용 ex API 호출
                    if let error = error {
                        print("DEBUG:  Error is \(error.localizedDescription)")
                        return
                    }
                    
                    print("성공적으로 사용자 등록")
                    // 성공시 사용자에게 할당되는 고유의 uid를 가져옴, 데이터베이스에 저장할때 사용자 고유의 데이터를 관리하기 위함임
                    guard let uid = result?.user.uid else {return}
                    
                    let values = ["email" : email,
                                  "username" : username,
                                  "fullname" : fullname,
                                  "profileImageUrl" : profileImageUrl]
                    
                    // 딕셔너리를 만듬
                    REF_USERS.updateChildValues(values) { (error, ref) in
                        print("사용자 정보를 성공적으로 업데이트")
                        //이 완료 블록에서 API 호출이 완료되고 성공합니다.
                    }
                    
            }
        }
        
       
            
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
