//
//  TabBarController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    private let disposeBag = DisposeBag()
    private var rootViewControllers: [UIViewController] = []
    private let loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
        bindAction()
        bindViewModel()
        setupNotification()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .white
        tabBar.barTintColor = .white
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        var viewControllers: [UIViewController] = []
        TabBar.allCases.forEach {
            let rootViewController = $0.rootViewController
            viewControllers.append(createNavigationController(rootViewController: rootViewController,
                                                              title: $0.title,
                                                              image: $0.image))
            rootViewControllers.append(rootViewController)
        }
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
    }
    
    private func bindAction() {
        rootViewControllers.forEach {
            $0.navigationItem.rightBarButtonItem?.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    //FIXME: if loginManager.isLogined { // 로그인 되어있으면
                    if KeychainManager.shared.readAccessToken(key: "accessToken") != nil {
                        self?.loginViewModel.action.didTappedLogoutButton.onNext(())
                    } else { // 로그인 X
                        self?.loginViewModel.action.didTappedLoginButton.onNext(())
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func bindViewModel() {
        loginViewModel.state.isLogout
            .subscribe(onNext: { [weak self] isLogoutSuccess in
                if isLogoutSuccess {
                    self?.rootViewControllers.forEach { [weak self] _ in
                        self?.setupNavigationBarRightButtonItem(size: (width: 28, height: 28), imageName: "login")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx.notification(.loginSuccess)
            .subscribe(onNext: { [weak self] _ in
                print("login noti 수신")
                self?.rootViewControllers.forEach { [weak self] _ in
                    self?.setupNavigationBarRightButtonItem(size: (width: 28, height: 28), imageName: "logout")
                }
            }).disposed(by: disposeBag)
    }
    
    private func createNavigationController(rootViewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        setupTabBarItem(navigationController: navigationController, title: title, image: image)
        setupNavigationBar(navigationController: navigationController, rootViewController: rootViewController)
        
        return navigationController
    }
    
    private func setupTabBarItem(navigationController: UINavigationController, title: String, image: UIImage?) {
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.imageInsets = .init(top: 7, left: 0, bottom: 7, right: 0)
        navigationController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        navigationController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.setFont(type: .bold, size: 24)], for: .normal)
    }
    
    private func setupNavigationBar(navigationController: UINavigationController, rootViewController: UIViewController) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.setFont(type: .medium, size: 24)
        ]
        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        rootViewController.navigationItem.title = "GitHub"
        let resizedImage = UIImage(named: "login")?.resize(size: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        rootViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: resizedImage, style: .plain, target: self, action: nil)
    }
    
    func setupNavigationBarRightButtonItem(size: (width: Int, height: Int), imageName: String) {
        let resizedImage = UIImage(named: imageName)?.resize(size: CGSize(width: size.width, height: size.height)).withRenderingMode(.alwaysOriginal)
        self.rootViewControllers.forEach {
            $0.navigationItem.rightBarButtonItem?.image = resizedImage
        }
    }
}
