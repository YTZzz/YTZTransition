//
//  YTZPercentDrivenInteractiveController.swift
//  YTZTransition
//
//  Created by Sodapig on 01/07/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit



class YTZPercentDrivenInteractiveController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    var frontTransitionView: UIView!
    var backgroundTransitionView: UIView!
    var zoomImageView: UIImageView!
    fileprivate var startInteractionPoint = CGPoint.zero
    fileprivate var interactionLastTouchPoint = CGPoint.zero
    var zoomStartFrame: CGRect!
    var zoomFinalFrame: CGRect!
    private var transitionContext: UIViewControllerContextTransitioning?
    var dismissZoomOutPanGestureRecognizer: UIPanGestureRecognizer!
    var dismissSlidePanGestureRecognizer: UIPanGestureRecognizer!
    var isInteraction = false
    var frontVC: UIViewController?

    override init() {
        super.init()
        dismissZoomOutPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
        dismissZoomOutPanGestureRecognizer.delegate = self
        dismissSlidePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
        dismissSlidePanGestureRecognizer.delegate = self
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == dismissZoomOutPanGestureRecognizer {
            if let view = dismissZoomOutPanGestureRecognizer.view {
                let velocity = dismissZoomOutPanGestureRecognizer.velocity(in: view)
                if velocity.y > 0 && fabs(velocity.x / velocity.y) < 0.75 {
                    return true
                }
            }
        }
        if gestureRecognizer == dismissSlidePanGestureRecognizer {
            if let view = dismissSlidePanGestureRecognizer.view {
                let velocity = dismissSlidePanGestureRecognizer.velocity(in: view)
                if fabs(velocity.x / velocity.y) < 0.75 {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Gesture
    func handleDismissPanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer == dismissZoomOutPanGestureRecognizer {
            let touchPoint = panGestureRecognizer.location(in: panGestureRecognizer.view!)
            var progress = (touchPoint.y - startInteractionPoint.y) / UIScreen.main.bounds.height * 2
            if progress < 0 {
                progress = 0
            } else if progress > 0.9 {
                progress = 0.9
            }
            
            switch panGestureRecognizer.state {
            case .began:
                isInteraction = true
                startInteractionPoint = panGestureRecognizer.location(in: panGestureRecognizer.view!)
                interactionLastTouchPoint = startInteractionPoint
                if let vc = frontVC {
                    vc.ytz_zoomOutDismiss()
                }
            case .changed:
                let sizeRadio = (1 - progress / 4)
                guard let zoomImageView = self.zoomImageView else {
                    return
                }
                let width  = zoomStartFrame.width  * sizeRadio
                let height = zoomStartFrame.height * sizeRadio
                let x = zoomImageView.frame.minX + touchPoint.x - interactionLastTouchPoint.x + (zoomImageView.frame.width  - width ) / 2
                let y = zoomImageView.frame.minY + touchPoint.y - interactionLastTouchPoint.y + (zoomImageView.frame.height - height) / 2
                zoomImageView.frame = CGRect(x: x,
                                             y: y,
                                             width: width,
                                             height: height)
                update(progress)
                interactionLastTouchPoint = touchPoint
            case .ended:
                if progress > 0.15 && panGestureRecognizer.velocity(in: panGestureRecognizer.view!).y > -5 {
                    finish()
                } else {
                    cancel()
                }
                isInteraction = false
            case .cancelled:
                cancel()
                isInteraction = false
            case .failed:
                cancel()
                isInteraction = false
            default:
                break
            }
        } else if panGestureRecognizer == dismissSlidePanGestureRecognizer {
            
        }
    }

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    override func finish() {
        super.finish()
        frontVC = nil
        guard
            let backgroundTransitionView = self.backgroundTransitionView,
            let zoomImageView = self.zoomImageView,
            let zoomFinalFrame = self.zoomFinalFrame,
            let transitionContext = self.transitionContext
        else {
            return
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            zoomImageView.frame = zoomFinalFrame
        }, completion: {
            finished in
            if finished {
                backgroundTransitionView.isHidden = false
                zoomImageView.isHidden = true
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
            let zoomImageView = self.zoomImageView,
            let zoomStartFrame = self.zoomStartFrame
        else {
            return
        }
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            fromView?.alpha = 1
            zoomImageView.frame = zoomStartFrame
        }, completion: {
            finished in
            if finished {
                frontTransitionView.isHidden = false
                zoomImageView.removeFromSuperview()
                backgroundTransitionView.isHidden = false
                toView?.removeFromSuperview()
                transitionContext.completeTransition(false)
            }
        })
    }
}
