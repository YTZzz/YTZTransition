//
//  YTZPercentDrivenInteractiveController.swift
//  YTZTransition
//
//  Created by Sodapig on 01/07/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZPercentDrivenInteractiveController: UIPercentDrivenInteractiveTransition {
    
    var frontZoomView: UIView?
    var backgroundZoomView: UIView?
    var zoomView: UIView?
    var zoomStartFrame: CGRect?
    var zoomFinalFrame: CGRect?
    private var transitionContext: UIViewControllerContextTransitioning?
    private var leftDuration: Double {
        get {
            return Double((1 - percentComplete) * duration)
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    override func finish() {
        super.finish()
        guard
            let backgroundZoomView = self.backgroundZoomView,
            let zoomView = self.zoomView,
            let zoomFinalFrame = self.zoomFinalFrame,
            let transitionContext = self.transitionContext
        else {
            return
        }
        UIView.animate(withDuration: leftDuration, delay: 0, options: .curveEaseInOut, animations: {
            zoomView.frame = zoomFinalFrame
        }, completion: {
            finished in
            if finished {
                backgroundZoomView.isHidden = false
                zoomView.isHidden = true
                transitionContext.completeTransition(true)
            }
        })
    }
    
    override func cancel() {
        super.cancel()
        guard
            let transitionContext = self.transitionContext,
            let frontZoomView = self.frontZoomView,
            let backgroundZoomView = self.backgroundZoomView,
            let zoomView = self.zoomView,
            let zoomStartFrame = self.zoomStartFrame
        else {
            return
        }
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        UIView.animate(withDuration: leftDuration, delay: 0, options: .curveEaseInOut, animations: {
            fromView?.alpha = 1
            zoomView.frame = zoomStartFrame
        }, completion: {
            finished in
            if finished {
                frontZoomView.isHidden = false
                zoomView.removeFromSuperview()
                backgroundZoomView.isHidden = false
                toView?.removeFromSuperview()
                transitionContext.completeTransition(false)
            }
        })

    }
}
