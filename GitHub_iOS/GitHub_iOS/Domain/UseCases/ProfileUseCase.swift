//
//  ProfileUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol ProfileUseCase {
    func getUserData() -> Observable<User>
    func getUserStarRepositoryData(page: Int, perPage: Int) -> Observable<[UserRepository]>
}

final class DefaultProfileUseCase: ProfileUseCase {
    private let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func getUserData() -> Observable<User> {
        return profileRepository.getUserData()
    }

    func getUserStarRepositoryData(page: Int, perPage: Int) -> Observable<[UserRepository]> {
        return profileRepository.getUserStarRepositoryData(page: page, perPage: perPage)
    }
}
