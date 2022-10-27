//
//  ProfileRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol ProfileRepository {
    func getUserData() -> Observable<User>
    func getUserStarRepositoryData(page: Int, perPage: Int) -> Observable<[UserRepository]>
}
