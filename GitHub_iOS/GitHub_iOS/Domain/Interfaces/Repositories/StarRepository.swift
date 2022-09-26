//
//  StarRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/26.
//

import Foundation
import RxSwift

protocol StarRepository {
    func requestStar(fullName: String) -> Observable<Data>
    func requestUnstar(fullName: String) -> Observable<Data>
}
