//
//  YTZForwardAnimationController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/4/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZForwardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var backgroundTransitionView: UIView!
    private var frontTransitionView: UIView!
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let frontView = transitionContext.view(forKey: .to),
            let backgroundView = transitionContext.view(forKey: .from),
            let frontDelegate = transitionContext.viewController(forKey: .to) as? YTZTransitionFrontDelegate,
            let backgroundDelegate = transitionContext.viewController(forKey: .from) as? YTZTransitionBackgroundDelegate
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let indexPath = frontDelegate.indexPathForDismiss()
        frontTransitionView = frontDelegate.transitionViewForFrontVC()
        backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        
        let image = YTZTransitionController.getImage(from: backgroundTransitionView)
        let zoomView = UIImageView(image: image)
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true

        let zoomStartFrame = backgroundView.convert(backgroundTransitionView.frame, to: backgroundView)
        let zoomFinalFrame = YTZTransitionController.getAsceptFitFrame(image: image, frame: frontView.convert(frontTransitionView.frame, to: frontView))
        let maxZoomScale: CGFloat = 1.1
        let zoomMaxFrame = YTZTransitionController.getProjectionFrame(firstFrame: zoomStartFrame, secondFrame: zoomFinalFrame, radioThirdDividSecond: maxZoomScale)
        
        zoomView.frame = zoomStartFrame
        
        let containerView = transitionContext.containerView
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
            [weak self]
            finished in
            self?.frontTransitionView.isHidden = false
            UIView.animate(withDuration: duration * (1 - firstDurationRatio), delay: 0, options: .curveEaseOut, animations: {
                zoomView.frame = zoomFinalFrame
            }, completion: {
                finished in
                if finished {
                    backgroundView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            })
        })
    }
}
