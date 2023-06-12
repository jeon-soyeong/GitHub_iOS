//
//  DIContainer.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2023/06/05.
//

import Foundation

final class DIContainer {
    static var shared = DIContainer()
    private var dependencies: [String: Any] = [:]
    
    private init() { }
    

    func register<T>(type: T.Type, service: Any) {
        dependencies["\(type)"] = service
    }

    func resolve<T>(type: T.Type) -> T {
        let key = "\(type)"
        let dependency = dependencies[key] as? T
        precondition(dependency != nil, "\(key)는 register 되지 않았어요.")

        return dependency!
    }
}
