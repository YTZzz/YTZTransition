//
//  YTZPercentDrivenInteractiveController.swift
//  YTZTransition
//
//  Created by Sodapig on 01/07/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZPercentDrivenInteractiveController: UIPercentDrivenInteractiveTransition {
    
    var frontTransitionView: UIView?
    var backgroundTransitionView: UIView?
    var zoomView: UIView?
    var zoomStartFrame: CGRect?
    var zoomFinalFrame: CGRect?
    private var transitionContext: UIViewControllerContextTransitioning?

    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    override func finish() {
        super.finish()
        guard
            let backgroundTransitionView = self.backgroundTransitionView,
            let zoomView = self.zoomView,
            let zoomFinalFrame = self.zoomFinalFrame,
            let transitionContext = self.transitionContext
        else {
            return
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            zoomView.frame = zoomFinalFrame
        }, completion: {
            finished in
            if finished {
                backgroundTransitionView.isHidden = false
                zoomView.isHidden = true
                transitionContext.completeTransition(true)
            }
        })
    }
    
    override func cancel() {
        super.cancel()
        guard
            let transitionContext = self.transitionContext,
            let frontTransitionView = self.frontTransitionView,
            let backgroundTransitionView = self.backgroundTransitionView,
            let zoomView = self.zoomView,
            let zoomStartFrame = self.zoomStartFrame
        else {
            return
        }
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            fromView?.alpha = 1
            zoomView.frame = zoomStartFrame
        }, completion: {
            finished in
            if finished {
                frontTransitionView.isHidden = false
                zoomView.removeFromSuperview()
                backgroundTransitionView.isHidden = false
                toView?.removeFromSuperview()
                transitionContext.completeTransition(false)
            }
        })
    }
}
