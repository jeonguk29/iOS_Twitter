//
//  NotificationCell.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/14.
//

import UIKit

// 알림 셀 구현 
class NotificationCell: UITableViewCell {

    // MARK: - Properties
    var notification: Notification? {
        didSet {configure()}
    }
    
    private lazy var profileImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 40, height: 40)
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .twitterBlue

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true

        return iv
    }()

    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification message"

        return label
    }()

    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
        stack.spacing = 8
        stack.alignment = .center

        addSubview(stack)
        // 스택 y축 에맞게 왼쪽, 오른쪽 고정
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        stack.anchor(right: rightAnchor, paddingRight: 12)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selector
    @objc func handleProfileImageTapped() {

    }
    
    
    // MARK: - Helpers
    func configure() {
        // 알림이 들어온 순간 실행 되며 viewModel에서 동적값을 전달 받아 적용함
        guard let notification = notification else { return }
        
        let viewModel = NotificationViewModel(notification: notification)
        
        profileImageView.sd_setImage(with: viewModel.profileImageURL)
        notificationLabel.attributedText = viewModel.notificationText
    }
}
