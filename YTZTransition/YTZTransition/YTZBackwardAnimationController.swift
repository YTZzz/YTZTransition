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
    var zoomImageView: UIImageView!
    var zoomStartFrame: CGRect!
    var zoomFinalFrame: CGRect!
    var transitionContext: UIViewControllerContextTransitioning!
    var startTouchPoint: CGPoint = .zero
    var lastTouchPoint: CGPoint = .zero
    var frontVC: UIViewController?
    var backwardType: YTZTransitionBackwardType = .dismiss

    
    // MARK: - Init
    override init() {
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        guard
            let frontView = transitionContext.viewController(forKey: .from)?.view,
            let backgroundView = transitionContext.viewController(forKey: .to)?.view,
            let frontDelegate = transitionContext.viewController(forKey: .from) as? YTZTransitionFrontDelegate,
            let backgroundDelegate = transitionContext.viewController(forKey: .to) as? YTZTransitionBackgroundDelegate
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
        zoomFinalFrame = backgroundView.convert(backgroundTransitionView.frame, to: backgroundView)
        zoomImageView.frame = zoomStartFrame
        containerView.addSubview(zoomImageView)
        
        if transitionContext.isInteractive {
            // 交互
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
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
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                [weak self] in
                frontView.alpha = 0
                self?.zoomImageView.frame = (self?.zoomFinalFrame)!
            }, completion: {
                [weak self]
                finished in
                let cancelled = transitionContext.transitionWasCancelled
                self?.zoomImageView.removeFromSuperview()
                if !cancelled {
                    frontView.removeFromSuperview()
                }
                transitionContext.completeTransition(!cancelled)
            })
        }
    }

    // Custom
    func startInteractiveTransition(touchPoint: CGPoint) {
        self.startTouchPoint = touchPoint
        if let vc = frontVC {
            if backwardType == .pop {
                _ = vc.navigationController?.popViewController(animated: true)
            } else if backwardType == .dismiss {
                vc.ytz_dismiss()
            }
        }
    }
    func updateInteractiveTransition(touchPoint: CGPoint){
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
    }
    func endInteractiveTransition(touchPoint: CGPoint, velocity: CGPoint) {
        let progress = getZoomOutProgress(by: touchPoint)
        if progress > 0.15 && velocity.y > -5 {
            finishInteractiveTransition()
        } else {
            cancelInteractiveTransition()
        }
    }
    private func finishInteractiveTransition() {
        guard
            let backgroundTransitionView = backgroundTransitionView,
            let zoomImageView = zoomImageView,
            let zoomFinalFrame = zoomFinalFrame,
            let transitionContext = transitionContext
        else {
            return
        }
        transitionContext.finishInteractiveTransition()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
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
        transitionContext.cancelInteractiveTransition()
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
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
}
