//
//  APIConstants.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

struct APIConstants {
    static let githubLoginBaseURL = "https://github.com"
    static let baseURL = "https://api.github.com"

    static var clientID: String {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "clientID") as? String else {
            fatalError("Couldn't find key 'clientID' in 'Info.plist'.")
        }
        return value
    }
    
    static var clientSecret: String {
        guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            fatalError("Couldn't find file 'Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "clientSecret") as? String else {
            fatalError("Couldn't find key 'clientSecret' in 'Info.plist'.")
        }
        return value
    }
}
