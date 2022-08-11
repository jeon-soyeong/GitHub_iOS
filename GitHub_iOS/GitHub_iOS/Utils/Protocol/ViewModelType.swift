//
//  ViewModelType.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation

import RxSwift

protocol ViewModelType {
    associatedtype Action
    associatedtype State
    
    var disposeBag: DisposeBag { get set }
}
