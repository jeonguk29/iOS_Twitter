//
//  Utilities.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit
// 재사용성을 위해 입력 컨테이너 뷰 리팩터링
// 단순 UI작업을 위해 반복하는 코드가 많기 때문에 해당 클레스를 만들어 반복작업을 최소한으로 할 것임

class Utilities {
    
    func inputContaimerView(withImage image: UIImage, textField: UITextField) -> UIView {
            
        let view = UIView()
        let iv = UIImageView()
        // 해당 뷰를 반환할때마다 높이 제한은 항상 50임 
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iv.image = image
        // 하위 뷰로 넣어주기
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 8, paddingBottom: 8)
        iv.setDimensions(width: 24, height: 24)
        
        // 컨테이너 보기에 텍스트 필드를 추가하고 이미지 오른쪽에 고정 
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor, bottom: view.bottomAnchor,
                         right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        
        return view
    }
    
    
}
