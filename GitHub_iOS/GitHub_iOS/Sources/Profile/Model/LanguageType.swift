//
//  LanguageType.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation
import UIKit

enum LanguageType {
    case swift, objectivec, java, javaScript, python, starlark, go, shell, ruby, kotlin, php, applescript, vue, css
    
    var text: String {
        switch self {
        case .swift:
            return "Swift"
        case .objectivec:
            return "Objective-C"
        case .java:
            return "Java"
        case .javaScript:
            return "JavaScript"
        case .python:
            return "Python"
        case .starlark:
            return "Starlark"
        case .go:
            return "Go"
        case .shell:
            return "Shell"
        case .ruby:
            return "Ruby"
        case .kotlin:
            return "Kotlin"
        case .php:
            return "PHP"
        case .applescript:
            return "AppleScript"
        case .vue:
            return "Vue"
        case .css:
            return "CSS"
        }
    }
    
    var color: UIColor {
        switch self {
        case .swift:
            return #colorLiteral(red: 0.9430995584, green: 0.3169893026, blue: 0.2185589671, alpha: 1)
        case .objectivec:
            return #colorLiteral(red: 0.2644223571, green: 0.5575552583, blue: 1, alpha: 1)
        case .java:
            return #colorLiteral(red: 0.6915001869, green: 0.4492215514, blue: 0.1009980962, alpha: 1)
        case .javaScript:
            return #colorLiteral(red: 0.9476673007, green: 0.8801721334, blue: 0.3548744321, alpha: 1)
        case .python:
            return #colorLiteral(red: 0.20729357, green: 0.4471886158, blue: 0.6466436386, alpha: 1)
        case .starlark:
            return #colorLiteral(red: 0.4621267319, green: 0.8254018426, blue: 0.4589958191, alpha: 1)
        case .go:
            return #colorLiteral(red: 0, green: 0.6802310348, blue: 0.8474339843, alpha: 1)
        case .shell:
            return #colorLiteral(red: 0.5272356272, green: 0.8579975367, blue: 0.3099059165, alpha: 1)
        case .ruby:
            return #colorLiteral(red: 0.1568627451, green: 0.4128328562, blue: 0.8116765618, alpha: 1)
        case .kotlin:
            return #colorLiteral(red: 0.6646007895, green: 0.4815580845, blue: 1, alpha: 1)
        case .php:
            return #colorLiteral(red: 0.3108789623, green: 0.3676162362, blue: 0.5832952857, alpha: 1)
        case .applescript:
            return #colorLiteral(red: 0.06055627018, green: 0.1217628196, blue: 0.1220867559, alpha: 1)
        case .vue:
            return #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        case .css:
            return #colorLiteral(red: 0.3384353518, green: 0.2395200133, blue: 0.4885692, alpha: 1)
        }
    }
}
