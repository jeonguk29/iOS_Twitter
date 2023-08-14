//
//  NotificationsController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//


import UIKit
private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet {
            tableView.reloadData()
        }
    } // 알림 배열 만들기 : 현재 사용자가 받은 알림들을 담기위한
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchNotifications()
    }
    override func viewWillAppear(_ animated: Bool) {
        // 프로필로 이동하고 다시 올때 네비게이션바가 다시 보일 수 있도록
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - API
    func fetchNotifications() {
        NotificationService.shared.fetchNotifications { (notifications) in
            self.notifications = notifications
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier) // 셀 등록
        tableView.rowHeight = 60 // 셀 높이 설정
        tableView.separatorStyle = .none // 셀 구분선 없애기
    }
    
}


// MARK: - UITableViewDataSource

extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 알림 종류에 맞춰 기능 구현하기, 좋아요 누른 트윗 가져와 표시해주기
        let notification = notifications[indexPath.row]
        print("DEBUG: Tweet id is \(notification.tweetID)")
        // DEBUG: Tweet id is Optional("-NbmZWTCWHNu10HoWyR1") 트윗 id 잘 넘어옴
                
        
        // 오류나는 것을 수정 : 속성 기본값 때문에 크래시 나는걸 방지하고 해당 라인 만나면 탈출 하기 때문에 아래 코드 라인까지 가지 않아서 크래시 충돌나지 않음
        guard let tweetID = notification.tweetID else { return }

        TweetService.shared.fetchTweet(with: tweetID) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        // 이제 클릭하면 데이터베이스에서 내 트윗을 가져오고 실제로 채워짐
    }
}

// MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    
    // 셀에서 알림과 연결된 사용자 가져오기 : 프로필 이미지 클릭시
    func didTapProfileImage(_ cell: NotificationCell) {
        // 셀에 사용자 정보가 있기 때문에 가능
        print("Profile image tapped!")
        guard let user = cell.notification?.user else { return }

        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
