//
//  ActionSheetLauncher.swift
//  iOS_Twitter
//
//  Created by 정정욱 on 2023/08/08.
//

import UIKit

class ActionSheetLauncher: NSObject {

    // MARK: - Properties
    
    private let user: User

    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
    }

    // MARK: - Helpers
    
    func show() {
        print("DEBUG: Show action sheet for user \(user.username)")
    }
}
