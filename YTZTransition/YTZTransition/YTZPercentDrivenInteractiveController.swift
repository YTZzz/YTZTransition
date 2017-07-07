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
    var backwardType: YTZTransitionBackwardType = .dismiss
    weak var frontVC: UIViewController?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var isInteraction = false

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
            var progress = backwardAnimationController.updateInteractiveTransition(touchPoint: touchPoint)
            if progress > 0.78 {
                progress = 0.78
            }
            update(progress)
        case .ended:
            let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)
            let finished = backwardAnimationController.endInteractiveTransition(touchPoint: touchPoint, velocity: velocity)
            if finished {
                finish()
            } else {
                cancel()
            }
            isInteraction = false
        case .cancelled:
            backwardAnimationController.cancelInteractiveTransition()
            cancel()
            isInteraction = false
        default:
            break
        }
    }
}
