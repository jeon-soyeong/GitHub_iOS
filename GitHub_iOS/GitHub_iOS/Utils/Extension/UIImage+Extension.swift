//
//  UIImage+Extension.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import Foundation
import UIKit

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
