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
    var zoomImageView: UIImageView!
    
    override init() {
        super.init()
    }
    
    init(backgroundTransitionView: UIView, frontTransitionView: UIView) {
        super.init()
        animationType = .zoomOut
        self.backgroundTransitionView = backgroundTransitionView
        self.frontTransitionView = frontTransitionView
        let image = YTZTransitionController.getImage(from: backgroundTransitionView)
        zoomImageView = UIImageView(image: image)
        zoomImageView.contentMode = .scaleAspectFill
        zoomImageView.clipsToBounds = true
        zoomImageView.backgroundColor = frontTransitionView.backgroundColor
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
        
        switch animationType {
            
        case .slide:
            // 滑动 交互
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                frontView.alpha = 0
            }, completion: {
                finished in
                if finished {
                    let cancelled = transitionContext.transitionWasCancelled
                    if !cancelled {
                        frontView.removeFromSuperview()
                    }
                }
            })
            
        case .zoomOut:
            // 缩小
            let zoomStartFrame = YTZTransitionController.getAsceptFitFrame(image: zoomImageView.image!, frame: frontView.convert(frontTransitionView.frame, to: frontView))
            zoomImageView.frame = zoomStartFrame
            containerView.addSubview(zoomImageView)

            if transitionContext.isInteractive {
                // 交互
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    frontView.alpha = 0
                }, completion: {
                    finished in
                    if finished {
                        let cancelled = transitionContext.transitionWasCancelled
                        if !cancelled {
                            frontView.removeFromSuperview()
                        }
                    }
                })
                
            } else {
                // 非交互
                let zoomFinalFrame = backgroundView.convert(backgroundTransitionView.frame, to: backgroundView)
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    [weak self] in
                    frontView.alpha = 0
                    self?.zoomImageView.frame = zoomFinalFrame
                }, completion: {
                    [weak self]
                    finished in
                    if finished {
                        let cancelled = transitionContext.transitionWasCancelled
                        self?.zoomImageView.removeFromSuperview()
                        if !cancelled {
                            frontView.removeFromSuperview()
                        }
                        transitionContext.completeTransition(!cancelled)
                    }
                })
            }
        }
    }

}
