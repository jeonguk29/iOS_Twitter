//
//  EditProfileController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/21.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"

class EditProfileController: UITableViewController {

    // MARK: - Properties
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let imagePicker = UIImagePickerController()
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
    }


    // MARK: - API

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
        navigationItem.rightBarButtonItem?.isEnabled = false // 활성화
    }

    func configureTableView() {
        // 헤더등록 밑 델리게이트 설정
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        tableView.tableFooterView = UIView()
        
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
