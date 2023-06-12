//
//  StarUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/26.
//

import Foundation
import RxSwift

protocol StarUseCase {
    func requestStar(fullName: String) -> Observable<Data>
    func requestUnstar(fullName: String) -> Observable<Data>
}

final class DefaultStarUseCase: StarUseCase {
    @Dependency var starRepository: StarRepository

    func requestStar(fullName: String) -> Observable<Data> {
        return starRepository.requestStar(fullName: fullName)
    }

    func requestUnstar(fullName: String) -> Observable<Data> {
        return starRepository.requestUnstar(fullName: fullName)
    }
}
