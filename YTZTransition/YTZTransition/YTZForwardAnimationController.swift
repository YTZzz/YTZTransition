//
//  YTZForwardAnimationController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/4/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZForwardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var frontDelegate: YTZTransitionFrontDelegate?
    weak var backgroundDelegate: YTZTransitionBackgroundDelegate?

    private override init() {
        super.init()
    }
    
    init(frontDelegate: YTZTransitionFrontDelegate, backgroundDelegate: YTZTransitionBackgroundDelegate) {
        super.init()
        self.frontDelegate = frontDelegate
        self.backgroundDelegate = backgroundDelegate
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let frontView = transitionContext.viewController(forKey: .to)?.view,
            let backgroundView = transitionContext.viewController(forKey: .from)?.view,
            let frontDelegate = self.frontDelegate,
            let backgroundDelegate = self.backgroundDelegate
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let indexPath = frontDelegate.indexPathForDismiss()
        let frontTransitionView = frontDelegate.transitionViewForFrontVC()
        let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        
        let image = YTZTransitionController.getImage(from: backgroundTransitionView)
        let zoomView = UIImageView(image: image)
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true

        let containerView = transitionContext.containerView

        let zoomStartFrame = (backgroundTransitionView.superview?.convert(backgroundTransitionView.frame, to: backgroundView))!
        let zoomFinalFrame = YTZTransitionController.getAsceptFitFrame(image: image, frame: frontView.convert(frontTransitionView.frame, to: frontView))
        let maxZoomScale: CGFloat = 1.1
        let zoomMaxFrame = YTZTransitionController.getProjectionFrame(firstFrame: zoomStartFrame, secondFrame: zoomFinalFrame, radioThirdDividSecond: maxZoomScale)
        zoomView.frame = zoomStartFrame
        
        frontTransitionView.isHidden = true
        frontView.alpha = 0
        containerView.addSubview(frontView)
        containerView.addSubview(zoomView)
        
        let duration = transitionDuration(using: transitionContext)
        let firstDurationRatio = 14.0 / 24.0
        
        UIView.animate(withDuration: duration * firstDurationRatio, delay: 0, options: .curveEaseOut, animations: {
            zoomView.frame = zoomMaxFrame
            frontView.alpha = 1
        }, completion: {
            finished in
            if finished {
                UIView.animate(withDuration: duration * (1 - firstDurationRatio), delay: 0, options: .curveEaseOut, animations: {
                    zoomView.frame = zoomFinalFrame
                }, completion: {
                    finished in
                    if finished {
                        frontTransitionView.isHidden = false
                        zoomView.removeFromSuperview()
                        backgroundView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                })
            }
        })
    }
}
