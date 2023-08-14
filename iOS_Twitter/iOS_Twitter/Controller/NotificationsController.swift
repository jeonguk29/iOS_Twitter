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

   extension NotificationsController {
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return notifications.count
       }

       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell

           return cell
       }
   }
