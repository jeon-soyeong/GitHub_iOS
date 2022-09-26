//
//  DefaultSearchRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

final class DefaultSearchRepository: SearchRepository {
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Single<RepositoryInfo> {
        return APIService().request(GitHubAPI.getSearchRepositoryData(page: page, perPage: perPage, query: query))
    }
}
