//
//  Dependency.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2023/06/07.
//

import Foundation

@propertyWrapper class Dependency<T> {
    let wrappedValue: T
    
    init() {
        self.wrappedValue = DIContainer.shared.resolve(type: T.self)
    }
}
