//
//  LoginRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol LoginRepository {
    func getAccessToken(code: String) -> Observable<Token>
}
