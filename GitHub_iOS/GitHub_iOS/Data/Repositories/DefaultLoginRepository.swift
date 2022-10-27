//
//  DefaultLoginRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

final class DefaultLoginRepository: LoginRepository {
    func getAccessToken(code: String) -> Observable<Token> {
        return APIService().request(GitHubAPI.getAccessToken(code: code))
    }
}
