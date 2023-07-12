//
//  NotificationsController.swift
//  Twitter_Clone
//
//  Created by 정정욱 on 2023/07/12.
//


import UIKit

class NotificationsController: UIViewController{
    // MARK: - Properties
    
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
    }

}
