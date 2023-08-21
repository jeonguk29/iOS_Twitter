//
//  CaptionTextView.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/20.
//

import UIKit

class InputTextView: UITextView {

    // MARK: - Properties
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "what' s happening?"
        return label
    }()
    
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top:topAnchor, left: leftAnchor, paddingTop:8, paddingLeft:4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty

//        아래 코드를 위 한줄로 표현 가능
//        if text.isEmpty{
//            placeholderLabel.isHidden = false
//        } else {
//            placeholderLabel.isHidden = true
//        }
    }
}




