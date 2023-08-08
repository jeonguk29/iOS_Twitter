//
//  ActionSheetLauncher.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/08.
//

import UIKit

private let reuseIdentifier = "ActionSheetCell"

class ActionSheetLauncher: NSObject { //NSObject 이유

    // MARK: - Properties
    
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    
    private lazy var blackView: UIView = {
            let view = UIView()
            view.alpha = 0
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
            view.addGestureRecognizer(tap)
            return view
        }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
        configureTableView()
    }

    // MARK: - Selectors
      // 블랙부분 누르면 다시 원상태로 돌아오는 애니메이션을 적용
      @objc func handleDismissal() {
          UIView.animate(withDuration: 0.5) {
              self.blackView.alpha = 0
              self.tableView.frame.origin.y += 300
          }
      }
    
    // MARK: - Helpers
    
    func show() {
        //print("DEBUG: Show action sheet for user \(user.username)")
        
        // SceneDelegate 에서 사용한적 있었음
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
              self.window = window

        window.addSubview(blackView) // 이렇게 하면 UI 창의 전체 화면에 검은색 뷰를 추가할 수 있습니다.
                blackView.frame = window.frame
        
              window.addSubview(tableView)
              tableView.frame = CGRect(x: 0, y: window.frame.height , width: window.frame.width, height: 300)

        // 블랙 뷰를 서서히 적용 하는 애니메이션
              UIView.animate(withDuration: 0.5) {
                  self.blackView.alpha = 1
                  self.tableView.frame.origin.y -= 300
              }
    }
    
    func configureTableView() {
            tableView.backgroundColor = .red
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 60
            tableView.separatorStyle = .none
            tableView.layer.cornerRadius = 5
            tableView.isScrollEnabled = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - UITableViewDelegate
extension ActionSheetLauncher: UITableViewDelegate {

}

// MARK: - UITableViewDataSource
extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
}


