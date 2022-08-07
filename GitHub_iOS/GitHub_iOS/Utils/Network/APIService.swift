//
//  APIService.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

import RxSwift
import Moya

class APIService {
    static let shared = APIService()
    
    func request<T: Codable, API: TargetType>(_ target: API) -> Single<T> {
        return Single<T>.create { single in
            let provider = MoyaProvider<API>(session: DefaultSession.sharedSession)
            let request = provider.request(target) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let parsedResponse = try JSONDecoder().decode(T.self, from: response.data)
                        single(.success(parsedResponse))
                    } catch let error {
                        single(.failure(error))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
