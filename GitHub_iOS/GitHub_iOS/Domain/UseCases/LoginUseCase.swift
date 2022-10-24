//
//  LoginUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    func getAccessToken(code: String) -> Observable<Token>
}

final class DefaultLoginUseCase: LoginUseCase {
    private let loginRepository: LoginRepository
    
    init(loginRepository: LoginRepository) {
        self.loginRepository = loginRepository
    }
    
    func getAccessToken(code: String) -> Observable<Token> {
        return loginRepository.getAccessToken(code: code)
    }
}
