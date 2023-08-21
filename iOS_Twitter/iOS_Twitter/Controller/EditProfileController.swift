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
        // 헤더등록 밑 델리게이트 설정
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        tableView.tableFooterView = UIView()
        
        // 셀등록
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count // 3개의 case가 있음
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell

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

// MARK: - UITableViewDataSource
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {

    }
}


