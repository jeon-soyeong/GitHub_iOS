//
//  LoginUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func getAccessToken(code: String) -> Single<[String: String]>
}

final class DefaultLoginUseCase: LoginUseCase {
    private let loginRepository: LoginRepository
    
    init(loginRepository: LoginRepository) {
        self.loginRepository = loginRepository
    }
    
    func getAccessToken(code: String) -> Single<[String: String]> {
        return loginRepository.getAccessToken(code: code)
    }
}
