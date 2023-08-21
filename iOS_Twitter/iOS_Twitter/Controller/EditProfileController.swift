//
//  EditProfileController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/21.
//

import UIKit

class EditProfileController: UITableViewController {

    // MARK: - Properties
    private let user: User
    private lazy var headerView = EditProfileHeader(user: user)

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
          tableView.tableHeaderView = headerView
          headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
          headerView.delegate = self
          tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {

    }
}
