//
//  GitHubAPI.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

import Moya

enum GitHubAPI {
    case requestAccessToken(code: String)
}

extension GitHubAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .requestAccessToken:
            return URL(string: APIConstants.baseUrl)!
        }
    }
    
    var path: String {
        switch self {
        case .requestAccessToken:
            return "/login/oauth/access_token"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestAccessToken:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .requestAccessToken(let code):
            let parameters = ["client_id": APIConstants.clientID,
                              "client_secret": APIConstants.clientSecret,
                              "code": code] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .requestAccessToken:
            return ["Accept": "application/json"]
        }
    }
}
