//
//  YTZPercentDrivenInteractiveController.swift
//  YTZTransition
//
//  Created by Sodapig on 01/07/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZPercentDrivenInteractiveController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    var backwardAnimationController: YTZBackwardAnimationController!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var isInteraction = false
    var frontVC: UIViewController?
    var backwardType: YTZTransitionBackwardType = .dismiss

    override init() {
        super.init()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        panGestureRecognizer.delegate = self
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            if let view = panGestureRecognizer.view {
                let velocity = panGestureRecognizer.velocity(in: view)
                if velocity.y > 0 && fabs(velocity.x / velocity.y) < 0.75 {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Gesture
    func handlePanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let touchPoint = panGestureRecognizer.location(in: panGestureRecognizer.view!)
        switch panGestureRecognizer.state {
        case .began:
            isInteraction = true
            if let vc = frontVC {
                if backwardType == .pop {
                    _ = vc.ytz_pop()
                } else if backwardType == .dismiss {
                    vc.ytz_dismiss()
                }
            }
            backwardAnimationController.startInteractiveTransition(touchPoint: touchPoint)
        case .changed:
            backwardAnimationController.updateInteractiveTransition(touchPoint: touchPoint)
        case .ended:
            let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
            backwardAnimationController.endInteractiveTransition(touchPoint: touchPoint, velocity: velocity)
            isInteraction = false
        case .cancelled:
            backwardAnimationController.cancelInteractiveTransition()
            isInteraction = false
        default:
            break
        }
    }
}
