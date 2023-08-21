//
//  EditProfileCell.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/21.
//

import UIKit

class EditProfileCell: UITableViewCell {

    // MARK: - Properties
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return tf
    }()
    
    // 기존에 CaptionTextView를=> InputTextView로 리팩토링해서 사용
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .twitterBlue
        tv.placeholderLabel.text = "Bio"
        return tv
    }()
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

               contentView.addSubview(titleLabel)
               titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
               titleLabel.anchor(top: topAnchor,
                                 left: leftAnchor,
                                 paddingTop: 12,
                                 paddingLeft: 16)

               contentView.addSubview(infoTextField)
               infoTextField.anchor(top: topAnchor,
                                    left: titleLabel.rightAnchor,
                                    bottom: bottomAnchor,
                                    right: rightAnchor,
                                    paddingTop: 4,
                                    paddingLeft: 16,
                                    paddingBottom: 8)

               contentView.addSubview(bioTextView)
               bioTextView.anchor(top: topAnchor,
                                  left: titleLabel.rightAnchor,
                                  bottom: bottomAnchor,
                                  right: rightAnchor,
                                  paddingTop: 4,
                                  paddingLeft: 16,
                                  paddingBottom: 8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleUpdateUserInfo() {
        
    }
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
    }

}
