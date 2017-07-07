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
        return 0.375
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let frontView = transitionContext.viewController(forKey: .to)?.view,
            let backgroundVC = transitionContext.viewController(forKey: .from),
            let backgroundView = backgroundVC.view,
            let frontDelegate = self.frontDelegate,
            let backgroundDelegate = self.backgroundDelegate
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let indexPath = frontDelegate.indexPathForDismissOrPop()
        let frontTransitionView = frontDelegate.transitionViewForFrontVC()
        let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        
        let containerView = transitionContext.containerView
        frontView.alpha = 0
        frontTransitionView.isHidden = true

        let image = YTZTransitionController.getImage(from: backgroundTransitionView)
        let zoomStartFrame = backgroundDelegate.transitionViewFrameInWindowForBackgroundVC(at: indexPath)
        print(zoomStartFrame)
        let zoomFinalFrame = YTZTransitionController.getAsceptFitFrame(image: image, frame: frontView.convert(frontTransitionView.frame, to: frontView))
        let maxZoomScale: CGFloat = 1.1
        let zoomMaxFrame = YTZTransitionController.getProjectionFrame(firstFrame: zoomStartFrame, secondFrame: zoomFinalFrame, radioThirdDividSecond: maxZoomScale)
        let zoomView = UIImageView(image: image)
        zoomView.frame = zoomStartFrame
        zoomView.contentMode = .scaleAspectFill
        zoomView.clipsToBounds = true
        
        let backgroundMaskView = UIView(frame: zoomStartFrame)
        backgroundMaskView.backgroundColor = .white
        containerView.addSubview(backgroundMaskView)
        containerView.addSubview(frontView)
        containerView.addSubview(zoomView)
        
        let duration = transitionDuration(using: transitionContext)
        let firstDurationRatio = 13.0 / 23.0

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
                        backgroundMaskView.removeFromSuperview()
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
