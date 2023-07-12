//
//  LoginController.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/07/12.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit // contentMode 속성은 이미지 뷰에 표시될 이미지의 크기 조정 및 배치 방법을 결정합니다. contentMode 속성을 .scaleAspectFit으로 설정하면 이미지를 가능한 크게 표시하면서도 이미지 뷰 영역 바깥으로 넘치지 않도록 이미지의 비율을 유지합니다.
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "TwitterLogo")
        // #imageLiteral() 이미지 리터럴

        return iv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: - Selectors
    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black // 해당 코드는 상태표시줄을 하얀색으로 만들어줌 ex 시간, 와이파이, 베터리 등
        navigationController?.navigationBar.isHidden = true // 네비게이션바 감추기
        
        // 이미지를 X축 중심에 있고, 화면 상단의 safeArea에 고정 시키기
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        // 오토레아웃 편하게 사용하기위해 만든 함수 중앙정렬, 어디기준으로 할건지, 기준에서 어디만큼 위치할건지 paddingTop: 0 이 기분값임
        logoImageView.setDimensions(width: 150, height: 150)
        // UIView 프로토콜에 추가된 확장 함수(extension function)로, 주어진 view의 너비와 높이를 변경합니다. 
    }
    
    
}
