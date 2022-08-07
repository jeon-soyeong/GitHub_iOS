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
                let loginManager = LoginManager.shared
                if loginManager.isLogined == false {
                    loginManager.openGithubLogin()
                }
            })
            .disposed(by: disposeBag)
    }
}
