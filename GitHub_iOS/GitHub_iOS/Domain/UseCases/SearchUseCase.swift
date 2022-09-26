//
//  SearchUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol SearchUseCase {
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Single<RepositoryInfo>
}

final class DefaultSearchUseCase: SearchUseCase {
    private let searchRepository: SearchRepository
    
    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }
    
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Single<RepositoryInfo> {
        return searchRepository.getSearchRepositoryData(page: page, perPage: perPage, query: query)
    }
}
