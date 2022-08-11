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
    
    private let loginLabel = UILabel().then {
        $0.text = "로그인이 필요합니다"
        $0.font = UIFont.setFont(type: .regular, size: 24)
    }
    
    private let loginButton = UIButton().then {
        let resizedImage = UIImage(named: "loginButton")?.resize(size: CGSize(width: 100, height: 100))
        $0.setImage(resizedImage, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindAction()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        view.addSubviews([loginLabel, loginButton])
    }
    
    private func setupConstraints() {
        loginLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loginButton.snp.top).offset(-10)
        }
        
        loginButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func bindAction() {
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
