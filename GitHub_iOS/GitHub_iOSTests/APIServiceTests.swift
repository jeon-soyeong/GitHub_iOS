//
//  APIServiceTests.swift
//  GitHub_iOSTests
//
//  Created by 전소영 on 2022/09/24.
//

import XCTest
import Moya
import RxSwift
@testable import GitHub_iOS

class APIServiceTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    func test_givenTestMoyaProviderAPIService_whenRequestGetUserData_ThenSuccess() throws {
        //given
        let customEndpointClosure = { (target: MultiTarget) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        let testingProvider = MoyaProvider<MultiTarget>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let apiService = APIService(provider: testingProvider)
        
        // when
        apiService.request(GitHubAPI.getUserData)
            .subscribe(onSuccess: { (user: User) in
                // then
                XCTAssertEqual(user.userID, "Jeon")
                XCTAssertEqual(user.userImageURL, "Jeon's Profile Image URL")
            }, onFailure: {
                print($0)
            })
            .disposed(by: self.disposeBag)
    }
}
