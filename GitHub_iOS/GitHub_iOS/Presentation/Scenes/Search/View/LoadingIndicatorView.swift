//
//  LoadingIndicatorView.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/09/21.
//

import Foundation
import UIKit

final class LoadingIndicatorView: UIView {
    private lazy var backgroundLayer = CAShapeLayer().then {
        $0.lineWidth = 3
        $0.strokeColor = UIColor.systemGray3.cgColor
        $0.fillColor = UIColor.clear.cgColor
        $0.lineCap = .round
        $0.frame = bounds
    }

    private lazy var indicatorLayer = CAShapeLayer().then {
        $0.lineWidth = 3
        $0.strokeColor = UIColor.lightGray.cgColor
        $0.fillColor = UIColor.clear.cgColor
        $0.lineCap = .round
        $0.frame = bounds
        $0.strokeEnd = 0.5
    }

    private lazy var circlePath = UIBezierPath().then {
        $0.addArc(withCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
                  radius: bounds.width / 3,
                  startAngle: -.pi / 2,
                  endAngle: .pi,
                  clockwise: true)
    }

    override func draw(_ rect: CGRect) {
        backgroundLayer.path = circlePath.cgPath
        indicatorLayer.path = circlePath.cgPath

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(indicatorLayer)
    }

    func startAnimation() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 2 * Float.pi
        rotateAnimation.duration = 0.5
        rotateAnimation.repeatCount = .infinity

        backgroundLayer.add(rotateAnimation, forKey: "rotate")
        indicatorLayer.add(rotateAnimation, forKey: "rotate")
    }
}
