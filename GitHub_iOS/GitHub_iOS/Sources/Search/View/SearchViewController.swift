//
//  SearchViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

class SearchViewController: UIViewController {
    private let label = UILabel().then {
        $0.text = "search"
        $0.font = UIFont.setFont(type: .bold, size: 32)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        view.addSubviews([label])
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
