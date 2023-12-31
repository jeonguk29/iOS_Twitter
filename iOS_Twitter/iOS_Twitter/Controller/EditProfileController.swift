//
//  EditProfileController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/21.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"
protocol EditProfileControllerDelegate: class {
    
    // 데이터 수정후 데이터 베이스 변경은 되지만 피드와 현제 수정후 변환된 값으로 리로드를 하기위한 프로토콜
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
    func handleLogout() // 로그아웃 버튼 클릭시 로그인 화면으로 돌아가기위한 메서드
}

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private lazy var footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    
    
    private var userInfoChanged = false
    
    private var imageChanged: Bool {
        return selectedImage != nil // 기본적으로 선택한 이미지에 값이 있으면 이미지가 변경되었음을 의미
    }
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var selectedImage: UIImage? {
        didSet { headerView.profileImageView.image = selectedImage }
    }
    
    // MARK: - Lifecycle
    init(user: User) {
        // 해당 컨트롤러는 사용자 정보로 채워져야함 초기화할때 사용자 정보 받는 부분이 필수
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureImagePicker()
        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        //        dismiss(animated: true, completion: nil)
        
        view.endEditing(true) // 완료를 누르면 보기 끝 편집이 사실이라고 말하고 싶습니다.
        // 둘중 하나의 데이터도 업데이트 되지 않으면 동작되지 않음
        guard imageChanged || userInfoChanged else { return }
        updateUserData()
    }
    
    
    // MARK: - API
    
    func updateUserData() {
        
        // 이런식으로 구분하여 API 호출 하는게 훨씬 효율적이고 불필요하게 저장되는 과부화를 막을 수 있음
        
        if imageChanged && !userInfoChanged {
            // 이미지가 업데이트 되었지만 사용자 정보는 업데이트 되지 않았을때
            print("이미지가 업데이트 되었지만 사용자 정보는 업데이트 되지 않았음")
            updateProfileImage()
        }
        
        if userInfoChanged && !imageChanged {
            // 사용자 정보는 업데이트 되었지만 이미지는 그대로일때
            print("사용자 정보는 업데이트 되었지만 이미지는 그대로")
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.delegate?.controller(self, wantsToUpdate: self.user)
            }
        }
        
        if userInfoChanged && imageChanged {
            // 둘다 업데이트 되었을때
            print("사용자 정보, 이미지 둘다 업데이트 ")
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.updateProfileImage()
            }
        }
    }
    
    func updateProfileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageURL in
            
            // 업데이트한 이미지 URL을 반환 받음 다시 화면에 적용하기
            self.user.profileImageUrl = profileImageURL
            self.delegate?.controller(self, wantsToUpdate: self.user)
            // 업데이트후 리로드를 위해 위임
        }
    }
        
        
        // MARK: - Helpers
        func configureNavigationBar() {
            
            navigationController?.navigationBar.barTintColor = .twitterBlue
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = .white
            
            
            // 네비게이션 바 타이틀 색상 설정
            navigationItem.title = "Edit Profile"
            
            
            // 네비게이션 바 아이템 설정
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(handleCancel))
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(handleDone))
            //navigationItem.rightBarButtonItem?.isEnabled = false // 활성화
        }
        
        func configureTableView() {
            // 헤더등록 밑 델리게이트 설정
            tableView.tableHeaderView = headerView
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
            headerView.delegate = self
            
            // 풋터 설정
            tableView.tableFooterView = footerView
            footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
            footerView.delegate = self
            
            // 셀등록
            tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        }
        
        func configureImagePicker() {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
        }
}

// MARK: - UITableViewDataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count // 3개의 case가 있음
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        
        cell.delegate = self
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell}
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        // 셀의 높이를 조절 bio 셀만 좀더 높이를 크게 100 아니면 다른 셀은 48로
        return option == .bio ? 100 : 48
    }
}


// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 사용자 프로필 이미지를 바꾸는 부분
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image //DidSet의 의하여 헤더에 바로 적용 되는 걸 확인 할 수 있음
        
        // 실제 사용자 정보를 업데이트 해주는 부분을 만들기만 하면 됨
        
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - EditProfileHeaderDelegate

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - EditProfileCellDelegate

extension EditProfileController: EditProfileCellDelegate {
    
    // 실제 사용자 정보를 업데이트 해주는 부분
    func updateUserInfo(_ cell: EditProfileCell) {
        
        guard let viewModel = cell.viewModel else { return }
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
            
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text // 값 자체가 옵셔널이라 그냥 넣으면 됨
        }
        
        print(user.fullname)
        print(user.username)
        print(user.bio)
    }
}

// MARK: - EditProfileFooterDelegate
extension EditProfileController: EditProfileFooterDelegate {
    func handleLogout() {
        
        // 로그아웃을 위한 Alert창 보여주기
        let alert = UIAlertController(title: nil,
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.dismiss(animated: true) { // 현제 보여지는 화면을 사라지게 하고
                self.delegate?.handleLogout()// 로그아웃 로직을 처리
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

