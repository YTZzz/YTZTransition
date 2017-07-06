//
//  YTZBackwardAnimationController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/4/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZBackwardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Variables
    var backgroundTransitionView: UIView!
    var frontTransitionView: UIView!
    private var transitionContext: UIViewControllerContextTransitioning!
    private var zoomImageView: UIImageView!
    private var zoomStartFrame: CGRect!
    private var zoomFinalFrame: CGRect!
    private var startTouchPoint: CGPoint = .zero
    private var lastTouchPoint: CGPoint = .zero
    var frontDelegate: YTZTransitionFrontDelegate?
    var backgroundDelegate: YTZTransitionBackgroundDelegate?
    
    // MARK: - Init
    private override init() {
        super.init()
    }
    
    init(frontDelegate: YTZTransitionFrontDelegate, backgroundDelegate: YTZTransitionBackgroundDelegate) {
        super.init()
        self.frontDelegate = frontDelegate
        self.backgroundDelegate = backgroundDelegate
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        guard
            let frontView = transitionContext.viewController(forKey: .from)?.view,
            let backgroundVC = transitionContext.viewController(forKey: .to),
            let backgroundView = backgroundVC.view,
            let frontDelegate = self.frontDelegate,
            let backgroundDelegate = self.backgroundDelegate
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let indexPath = frontDelegate.indexPathForDismiss()
        frontTransitionView = frontDelegate.transitionViewForFrontVC()
        backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        
        let image = YTZTransitionController.getImage(from: backgroundTransitionView)
        zoomImageView = UIImageView(image: image)
        zoomImageView.contentMode = .scaleAspectFill
        zoomImageView.clipsToBounds = true
        zoomImageView.backgroundColor = frontTransitionView.backgroundColor

        let containerView = transitionContext.containerView
        containerView.insertSubview(backgroundView, belowSubview: frontView)
        let duration = transitionDuration(using: transitionContext)
        
        zoomStartFrame = YTZTransitionController.getAsceptFitFrame(image: zoomImageView.image!, frame: frontView.convert(frontTransitionView.frame, to: frontView))
        zoomFinalFrame = YTZTransitionController.getFrameInTopView(from: backgroundTransitionView)
        zoomFinalFrame.origin.y += backgroundVC.topLayoutGuide.length
        zoomImageView.frame = zoomStartFrame
        containerView.addSubview(zoomImageView)
        frontTransitionView.isHidden = true
        backgroundTransitionView.isHidden = true
        
        if transitionContext.isInteractive {
            // 交互
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                frontView.alpha = 0
            }, completion: {
                finished in
                let cancelled = transitionContext.transitionWasCancelled
                if !cancelled {
                    frontView.removeFromSuperview()
                }
            })
            
        } else {
            // 非交互
            guard
                let zoomImageView = self.zoomImageView,
                let zoomFinalFrame = self.zoomFinalFrame,
                let frontTransitionView = self.frontTransitionView,
                let backgroundTransitionView = self.backgroundTransitionView
            else {
                transitionContext.completeTransition(false)
                return
            }
            releaseDelegate()
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                frontView.alpha = 0
                zoomImageView.frame = zoomFinalFrame
            }, completion: {
                finished in
                if finished {
                    frontView.removeFromSuperview()
                    frontTransitionView.isHidden = false
                    backgroundTransitionView.isHidden = false
                    zoomImageView.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            })
        }
    }

    // Custom
    func startInteractiveTransition(touchPoint: CGPoint) {
        self.startTouchPoint = touchPoint
        self.lastTouchPoint = touchPoint
    }
    func updateInteractiveTransition(touchPoint: CGPoint) -> CGFloat {
        let progress = getZoomOutProgress(by: touchPoint)
        let sizeRadio = (1 - progress / 4)
        let width  = zoomStartFrame.width  * sizeRadio
        let height = zoomStartFrame.height * sizeRadio
        let x = zoomImageView.frame.minX + touchPoint.x - self.lastTouchPoint.x + (zoomImageView.frame.width  - width ) / 2
        let y = zoomImageView.frame.minY + touchPoint.y - self.lastTouchPoint.y + (zoomImageView.frame.height - height) / 2
        zoomImageView.frame = CGRect(x: x,
                                     y: y,
                                     width: width,
                                     height: height)
        self.lastTouchPoint = touchPoint
        return progress
    }
    func endInteractiveTransition(touchPoint: CGPoint, velocity: CGPoint) -> Bool {
        let progress = getZoomOutProgress(by: touchPoint)
        if progress > 0.15 && velocity.y > -5 {
            finishInteractiveTransition()
            return true
        }
        cancelInteractiveTransition()
        return false
    }
    private func finishInteractiveTransition() {
        guard
            let backgroundTransitionView = backgroundTransitionView,
            let zoomImageView = zoomImageView,
            let zoomFinalFrame = zoomFinalFrame,
            let transitionContext = transitionContext
        else {
            self.transitionContext.finishInteractiveTransition()
            self.transitionContext.completeTransition(true)
            return
        }
        releaseDelegate()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            zoomImageView.frame = zoomFinalFrame
        }, completion: { finished in
            backgroundTransitionView.isHidden = false
            zoomImageView.isHidden = true
            transitionContext.completeTransition(true)
        })
    }
    func cancelInteractiveTransition() {
        guard
            let transitionContext = transitionContext,
            let frontTransitionView = frontTransitionView,
            let backgroundTransitionView = backgroundTransitionView,
            let zoomImageView = zoomImageView,
            let zoomStartFrame = zoomStartFrame,
            let backgtoundView = transitionContext.view(forKey: .to)
        else {
            return
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            zoomImageView.frame = zoomStartFrame
        }, completion: { finished in
            frontTransitionView.isHidden = false
            zoomImageView.removeFromSuperview()
            backgroundTransitionView.isHidden = false
            backgtoundView.removeFromSuperview()
            transitionContext.completeTransition(false)
        })
    }
    
    func getZoomOutProgress(by touchPoint: CGPoint) -> CGFloat {
        var progress = (touchPoint.y - startTouchPoint.y) / UIScreen.main.bounds.height * 2
        if progress < 0 {
            progress = 0
        } else if progress > 0.9 {
            progress = 0.9
        }
        return progress
    }
    
    func releaseDelegate() {
        frontDelegate = nil
        backgroundDelegate = nil
    }
}
