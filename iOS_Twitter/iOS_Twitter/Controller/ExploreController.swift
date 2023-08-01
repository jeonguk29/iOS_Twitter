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
    

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!
        UserCell
                
        return cell
    }
}
