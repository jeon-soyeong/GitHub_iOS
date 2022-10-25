//
//  SearchRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/25.
//

import Foundation
import RxSwift

protocol SearchRepository {
    func getSearchRepositoryData(page: Int, perPage: Int, query: String) -> Observable<RepositoryInfo>
}
