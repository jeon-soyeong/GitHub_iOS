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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTabBar()
        setupViewControllers()
        bindAction()
        setupNotification()
    }
    
    private func setupTabBar() {
        UITabBar.appearance().backgroundColor = .black
        tabBar.tintColor = .white
        tabBar.barTintColor = .white
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
                .subscribe(onNext: { [weak self] in
                    let loginManager = LoginManager.shared
                    //FIXME:
                    //if loginManager.isLogined { // 로그인 되어있으면
                    if KeychainManager.shared.readAccessToken(key: "accessToken") != nil {
                        loginManager.logout() { result in
                            switch result {
                            case .success():
                                print("logout 성공")
                                self?.rootViewControllers.forEach { [weak self] _ in
                                    self?.setupNavigationBarRightButtonItem(size: (width: 28, height: 28), imageName: "login") // 로그아웃처리 -> login image 보이도록 처리
                                }
                            case .failure(let error):
                                print(error)
                                self?.showToast(message: "로그아웃 실패.")
                            }
                        }
                    } else { // 로그인 X
                        loginManager.openGithubLogin()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx.notification(.loginSuccess)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                print("login noti 수신")
                self.rootViewControllers.forEach { [weak self] _ in
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
        navigationController.tabBarItem.imageInsets = .init(top: 15, left: 0, bottom: 0, right: 0)
        navigationController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
        navigationController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.setFont(type: .bold, size: 14)], for: .normal)
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
