//
//  APIService.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

import RxSwift
import Moya

final class APIService {
    private let provider: MoyaProvider<MultiTarget>

    init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>()) {
        self.provider = provider
    }

    func request<T: Codable, API: TargetType>(_ target: API) -> Single<T> {
        return Single<T>.create { single in
            let request = self.provider.request(MultiTarget(target)) { result in
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

    func request<T: Codable, API: TargetType>(_ target: API) -> Observable<T> {
        return Observable.create { observer in
            let request = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    do {
                        let parsedResponse = try JSONDecoder().decode(T.self, from: response.data)
                        observer.onNext(parsedResponse)
                    } catch let error {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }

    func request<API: TargetType>(_ target: API) -> Observable<Data> {
        return Observable.create { observer in
            let request = self.provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    observer.onNext(response.data)
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
