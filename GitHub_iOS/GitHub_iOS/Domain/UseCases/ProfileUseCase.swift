//
//  ProfileUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol ProfileUseCase {
    func getUserData() -> Single<User> 
    func getUserStarRepositoryData(page: Int, perPage: Int) -> Single<[UserRepository]>
}

final class DefaultProfileUseCase: ProfileUseCase {
    private let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }
    
    func getUserData() -> Single<User> {
        return profileRepository.getUserData()
    }

    func getUserStarRepositoryData(page: Int, perPage: Int) -> Single<[UserRepository]> {
        return profileRepository.getUserStarRepositoryData(page: page, perPage: perPage)
    }
}
