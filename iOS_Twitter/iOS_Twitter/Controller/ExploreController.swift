//
//  ExploreController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit

private let reuseIdentifier = "UserCell"

class ExploreController: UITableViewController{
    // MARK: - Properties
    
    private var users = [User]() {
        didSet{ tableView.reloadData() }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            //해당 코드는 users 배열의 요소를 하나씩 가져와 username 속성을 콘솔에 출력하는 코드입니다. forEach 함수는 배열과 같은 시퀀스에서 요소를 하나씩 순회하면서 작업을 수행하는 함수입니다.
//            users.forEach { user in
//                print("DEBUG: USER is \(user.username)")
//            }
            self.users = users
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Explore"
        
        //  재사용 셀에 재사용 식별자 등록
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none // 셀 사이에 구분선이 보이지 않게 설정
    }

}

extension ExploreController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!
        UserCell
        
        cell.user = users[indexPath.row]
        return cell
        
        /*
         테이블 뷰던, 컬렉션 뷰던 UI셋팅한뷰에 실제 사용자를 뿌려줄때 프로세스
         0. UITableViewController 같이 일단 컨트롤러 구현, 셀 구현 => test로 빈 데모 구현
         1. 필요한 API 함수 구현(어떤 데이터를 가져와 컨트롤러에 담을지)
         2.셀에 표시할 정보를 담을 속성을 만들기 ex user 💁 didSet을 활용해 UI에 실제 사용자 정보 대입
         3.컨트롤러로 돌아와서 셀 만들때 user를 넘겨주기    cell.user = users[indexPath.row] 해당 부분
            4.이전에 API 부분에서 fetchUsers를 구현해 users 배열에 사용자들을 담고 있는 상태여야함
         */
    }
}
