//
//  DefaultProfileRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

final class DefaultProfileRepository: ProfileRepository {
    let apiService = APIService()
    
    func getUserData() -> Single<User> {
        return apiService.request(GitHubAPI.getUserData)
    }
    
    func getUserStarRepositoryData(page: Int, perPage: Int) -> Single<[UserRepository]> {
        return APIService().request(GitHubAPI.getUserStarRepositoryData(page: page, perPage: perPage))
    }
}
