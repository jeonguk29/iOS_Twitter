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
