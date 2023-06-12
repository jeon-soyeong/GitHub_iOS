//
//  TabBar.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import Foundation
import UIKit

enum TabBar: CaseIterable {
    case search
    case profile

    var title: String {
        switch self {
        case .search:
            return "search"
        case .profile:
            return "profile"
        }
    }

    var image: UIImage? {
        switch self {
        case .search:
            return UIImage(named: "search")
        case .profile:
            return UIImage(named: "profile")
        }
    }

    var rootViewController: UIViewController {
        @Dependency var searchViewController: SearchViewController
        @Dependency var profileViewController: ProfileViewController
        
        switch self {
        case .search:
            return searchViewController
        case .profile:
            return profileViewController
        }
    }
}
