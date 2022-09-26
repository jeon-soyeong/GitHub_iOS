//
//  DefaultStarRepository.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/26.
//

import Foundation
import RxSwift

final class DefaultStarRepository: StarRepository {
    let apiService = APIService()
    
    func requestStar(fullName: String) -> Observable<Data> {
        let observable = apiService.request(GitHubAPI.requestStar(fullName: fullName))
        return observable
    }
    
    func requestUnstar(fullName: String) -> Observable<Data> {
        let observable = apiService.request(GitHubAPI.requestUnstar(fullName: fullName))
        return observable
    }
}
