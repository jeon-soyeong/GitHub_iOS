//
//  GitHubTests.swift
//  GitHub_iOSTests
//
//  Created by 전소영 on 2022/09/24.
//

import XCTest
import Moya
import RxSwift
@testable import GitHub_iOS

class GitHubTests: XCTestCase {
    let disposeBag = DisposeBag()
    var apiService: APIService?

    override func setUpWithError() throws {
        let customEndpointClosure = { (target: MultiTarget) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        let testingProvider = MoyaProvider<MultiTarget>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)

        apiService = APIService(provider: testingProvider)
    }

    func test_givenTestMoyaProviderAPIService_whenRequestGetUserData_ThenSuccess() throws {
        apiService?.request(GitHubAPI.getUserData)
            .subscribe(onSuccess: { (user: User) in
                XCTAssertEqual(user.userID, "Jeon")
                XCTAssertEqual(user.userImageURL, "Jeon's Profile Image URL")
            }, onFailure: {
                print($0)
            })
            .disposed(by: self.disposeBag)
    }
}
