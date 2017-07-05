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
    
    override init() {
        super.init()
    }
    
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
            let image = YTZTransitionController.getImage(from: backgroundTransitionView)
            let zoomStartFrame = YTZTransitionController.getAsceptFitFrame(image: image, frame: frontView.convert(frontTransitionView.frame, to: frontView))
            let zoomImageView = UIImageView(image: image)
            zoomImageView.frame = zoomStartFrame
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            zoomImageView.backgroundColor = frontTransitionView.backgroundColor
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
                    frontView.alpha = 0
                    zoomImageView.frame = zoomFinalFrame
                }, completion: {
                    finished in
                    if finished {
                        let cancelled = transitionContext.transitionWasCancelled
                        zoomImageView.removeFromSuperview()
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
