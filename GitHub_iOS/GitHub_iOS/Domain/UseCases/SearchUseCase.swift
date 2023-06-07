//
//  SearchUseCase.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol SearchUseCase {
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Observable<RepositoryInfo>
}

final class DefaultSearchUseCase: SearchUseCase {
    @Dependency var searchRepository: SearchRepository
    
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Observable<RepositoryInfo> {
        return searchRepository.getSearchRepositoryData(page: page, perPage: perPage, query: query)
    }
}
