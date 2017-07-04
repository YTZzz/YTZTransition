//
//  YTZBackwardAnimationController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/4/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZBackwardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animationType: YTZTransitionBackwardAnimationType = .slide
    private var backgroundTransitionView: UIView!
    private var frontTransitionView: UIView!
    
    init(backgroundTransitionView: UIView, frontTransitionView: UIView) {
        super.init()
        animationType = .zoomOut
        self.backgroundTransitionView = backgroundTransitionView
        self.frontTransitionView = frontTransitionView
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let backgroundView = transitionContext.view(forKey: .to),
            let frontView = transitionContext.view(forKey: .from)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let containerView = transitionContext.containerView
        containerView.insertSubview(backgroundView, belowSubview: frontView)
        let duration = transitionDuration(using: transitionContext)
        
        if transitionContext.isInteractive {
            
        } else {
            switch animationType {
            case .slide:
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    frontView.alpha = 0
                }, completion: {
                    finished in
                    if finished {
                        frontView.removeFromSuperview()
                    }
                })
            case .zoomOut:
                
            }
        }
    }

}
