//
//  EditProfileViewModel.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/21.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio

    var description: String {
        switch self {
        case .fullname: return "Name"
        case .username: return "Username"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {

    private let user: User
    let option: EditProfileOptions

    var titleText: String {
        return option.description
    }

    var optionValue: String? {
        switch option {

        case .fullname: return user.fullname
        case .username: return user.username
        case .bio: return user.bio
        }
    }

    /*
     옵션이 bio와 같으면 텍스트 필드를 숨기기.
     따라서 옵션이 bio일 때 텍스트 필드를 숨기고 텍스트 보기를 표시 
     bio와 같을때 텍스트 보기를 숨기고 텍스트 필드를 표시하려고 합니다.
     */
    var shouldHideTextField: Bool {
        return option == .bio
    }

    var shouldHideTextView: Bool {
        return option != .bio
    }

    var shouldHidePlaceholderLabel: Bool {
          return user.bio != nil // 값이 있다면 기본 표시되는 라벨 값 숨기기 
      }
    
    //이 뷰 모델은 데이터를 설정하기 위해 이 두 가지가 모두 필요
    // 각 셀의 title 제목을 넣기 위해 + 제목에 해당하는 실제 사용자 값을 넣기 위해
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
