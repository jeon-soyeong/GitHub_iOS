//
//  LoginViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import UIKit

import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let loginViewModel = LoginViewModel()
    
    let loginButton = UIButton().then {
        $0.setTitle("login", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        view.addSubview(loginButton)
        
        loginButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                //FIXME: 확인만
//                if self?.loginViewModel.isLogined == false {
                if KeychainManager.shared.readAccessToken(key: "accessToken") == nil {
                    self?.loginViewModel.action.didTappedLoginButton.onNext(())                    
                }
            })
            .disposed(by: disposeBag)
    }
}
