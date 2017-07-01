//
//  YTZTransitionController.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

protocol YTZTransitionFrontDelegate: class {
    func transitionViewForFrontVC() -> UIView
}
protocol YTZTransitionBackgroundDelegate: class {
    func transitionViewForBackgroundVC() -> UIView
}

class YTZTransitionController: NSObject, UIGestureRecognizerDelegate {
    
    static let shared = YTZTransitionController()
    
    weak var frontDelegate: YTZTransitionFrontDelegate?
    weak var backgroundDelegate: YTZTransitionBackgroundDelegate?
    var frontVC: UIViewController?
    var isDismissal = false
    var dismissPanGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var zoomImageView: UIImageView?
    
    fileprivate var isInteraction = false
    fileprivate var interactiveController: YTZPercentDrivenInteractiveController!
    fileprivate var startInteractionPoint = CGPoint.zero
    fileprivate var interactionLastTouchPoint = CGPoint.zero
    fileprivate var zoomImageViewStartInteractionFrame = CGRect.zero
    fileprivate var zoomImageViewFinishInteractionFrame: CGRect?
    
    private override init() {
        super.init()
        dismissPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
        dismissPanGestureRecognizer.delegate = self
        interactiveController = YTZPercentDrivenInteractiveController()
    }
    
    func handleDismissPanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        var progress: CGFloat = 0
        
        switch panGestureRecognizer.state {
        case .began:
            isInteraction = true
            startInteractionPoint = panGestureRecognizer.location(in: panGestureRecognizer.view!)
            interactionLastTouchPoint = startInteractionPoint
            print("startInteractionPoint: ", startInteractionPoint)
            if let vc = frontVC {
                vc.ytz_dismiss()
            }
        case .changed:
            let touchPoint = panGestureRecognizer.location(in: panGestureRecognizer.view!)
            progress = (touchPoint.y - startInteractionPoint.y) / UIScreen.main.bounds.height * 2
            if progress < 0 {
                progress = 0
            }

            let sizeRadio = (1 - progress / 4)
            guard let zoomImageView = self.zoomImageView else {
                return
            }
            let width  = zoomImageViewStartInteractionFrame.width  * sizeRadio
            let height = zoomImageViewStartInteractionFrame.height * sizeRadio
            let x = zoomImageView.frame.minX + touchPoint.x - interactionLastTouchPoint.x + (zoomImageView.frame.width  - width ) / 2
            let y = zoomImageView.frame.minY + touchPoint.y - interactionLastTouchPoint.y + (zoomImageView.frame.height - height) / 2
            zoomImageView.frame = CGRect(x: x,
                                         y: y,
                                         width: width,
                                         height: height)
            interactiveController.update(progress)
            interactionLastTouchPoint = touchPoint
        case .ended:
            if progress > 0.15 {
                interactiveController.finish()
            } else {
                interactiveController.cancel()
            }
            isInteraction = false
        case .cancelled:
            interactiveController.cancel()
            isInteraction = false
        case .failed:
            interactiveController.cancel()
            isInteraction = false
        default:
            break
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == dismissPanGestureRecognizer {
            guard let view = dismissPanGestureRecognizer.view else {
                return false
            }
            let velocity = dismissPanGestureRecognizer.velocity(in: view)
            if velocity.y > 0 && fabs(velocity.x / velocity.y) < 0.75 {
                return true
            }
        }
        return false
    }
    
    fileprivate func getImage(from View: UIView) -> UIImage {
        if View is UIImageView {
            let imageView = View as! UIImageView
            if let image = imageView.image {
                return image
            }
        }
        UIGraphicsBeginImageContextWithOptions(View.bounds.size, false, UIScreen.main.scale)
        View.drawHierarchy(in: View.bounds, afterScreenUpdates: false)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return image
        }
        return UIImage()
    }
}

extension YTZTransitionController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteraction ? interactiveController : nil
    }
}

extension YTZTransitionController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isDismissal ? 0.2 : 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }

        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        if isDismissal {
            
            guard let frontDelegate = self.frontDelegate, let backgroundDelegate = self.backgroundDelegate else {
                transitionContext.completeTransition(true)
                return
            }
            let frontTransitionView = frontDelegate.transitionViewForFrontVC()
            let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC()
            
            let image = getImage(from: frontTransitionView)
            zoomImageView = UIImageView(image: image)
            guard let zoomImageView = self.zoomImageView else {
                return
            }
            zoomImageView.frame = getAsceptFitFrame(image: image, frame: fromVC.view.convert(frontTransitionView.frame, to: fromVC.view))
            zoomImageViewStartInteractionFrame = zoomImageView.frame
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            zoomImageView.backgroundColor = fromVC.view.backgroundColor
            containerView.addSubview(zoomImageView)
            
            frontTransitionView.isHidden = true
            
            let zoomFinalFrame = toVC.view.convert(backgroundTransitionView.frame, to: toVC.view)
            frontTransitionView.isHidden = true
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            fromVC.view.backgroundColor = .white

            if isInteraction {
                backgroundTransitionView.isHidden = true
                interactiveController.backgroundZoomView = backgroundTransitionView
                interactiveController.zoomView = zoomImageView
                interactiveController.finalFrame = zoomFinalFrame
                zoomImageViewFinishInteractionFrame = zoomFinalFrame
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    fromVC.view.alpha = 0
                }, completion: {
                    finished in
                    if finished {
                        backgroundTransitionView.isHidden = false
                        transitionContext.completeTransition(true)
                    }
                })
            } else {
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                    zoomImageView.frame = zoomFinalFrame
                    fromVC.view.alpha = 0
                    }, completion: {
                        finished in
                        if finished {
                            fromVC.view.removeFromSuperview()
                            transitionContext.completeTransition(true)
                        }
                })
            }

        } else {
            
            guard let frontDelegate = self.frontDelegate, let backgroundDelegate = self.backgroundDelegate else {
                transitionContext.completeTransition(true)
                return
            }
            let frontTransitionView = frontDelegate.transitionViewForFrontVC()
            let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC()
            
            let image = getImage(from: backgroundTransitionView)
            zoomImageView = UIImageView(image: image)
            guard let zoomImageView = self.zoomImageView else {
                return
            }
            let zoomFinalFrame = getAsceptFitFrame(image: image, frame: toVC.view.convert(frontTransitionView.frame, to: toVC.view))
            zoomImageView.frame = fromVC.view.convert(backgroundTransitionView.frame, to: fromVC.view)
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            zoomImageView.backgroundColor = backgroundTransitionView.backgroundColor
            containerView.addSubview(zoomImageView)

            let maxZoomScale: CGFloat = 1.1
            let maxZoomFrame = getProjectionFrame(smallFrame: zoomImageView.frame, largeFrame: zoomFinalFrame, radioFinalDividLarge: maxZoomScale)
            
            let firstDurationRatio = 14.0 / 24.0

            frontTransitionView.isHidden = true
            toVC.view.alpha = 0
            containerView.insertSubview(toVC.view, belowSubview: zoomImageView)
            
            UIView.animate(withDuration: duration * firstDurationRatio, delay: 0, options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                zoomImageView.frame = maxZoomFrame
                toVC.view.alpha = 1
                }, completion: {
                    finished in
                    if finished {
                        UIView.animate(withDuration: duration * (1 - firstDurationRatio), animations: {
                            zoomImageView.frame = zoomFinalFrame
                        }, completion: {
                                finished in
                                if finished {
                                    frontTransitionView.isHidden = false
                                    zoomImageView.removeFromSuperview()
                                    fromVC.view.removeFromSuperview()
                                    transitionContext.completeTransition(true)
                                }
                        })
                    }
            })
        }
    }
}

//extension YTZTransitionController: UIViewControllerInteractiveTransitioning {
//    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
//        self.transitionContext = transitionContext
//    }
//    
//    func updateInteraction(progress: CGFloat) {
//        transitionContext?.updateInteractiveTransition(progress)
//    }
//    
//    func cancleInteraction() {
//        transitionContext?.cancelInteractiveTransition()
//    }
//    
//    func finishInteraction() {
//        if let zoomImageView = self.zoomImageView, let finalFrame = zoomImageViewFinishInteractionFrame {
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
//                zoomImageView.frame = finalFrame
//            }, completion: {
//                finished in
//                if finished {
//                    zoomImageView.removeFromSuperview()
//                }
//            })
//        }
//        transitionContext?.completeTransition(true)
//    }
//}

extension YTZTransitionController {
    func getAsceptFitFrame(image: UIImage, frame: CGRect) -> CGRect {
        let imageSize = image.size
        let viewSize = frame.size
        let imageWDividH = imageSize.width / imageSize.height
        let viewWDividH = viewSize.width / viewSize.height
        var finalFrame = CGRect.zero
        if imageWDividH > viewWDividH {
            let height = viewSize.width / imageWDividH
            finalFrame = CGRect(x: frame.minX,
                                y: frame.minY + (viewSize.height - height) / 2,
                                width: viewSize.width,
                                height: height)
        } else {
            let width = viewSize.height * imageWDividH
            finalFrame = CGRect(x: frame.minX + (viewSize.width - width) / 2,
                                y: frame.minY,
                                width: width,
                                height: viewSize.height)
        }
        return finalFrame
    }
    
    func getProjectionFrame(smallFrame: CGRect, largeFrame: CGRect, radioFinalDividLarge: CGFloat) -> CGRect {
        
        let finalSize = CGSize(width: largeFrame.width * radioFinalDividLarge, height: largeFrame.height * radioFinalDividLarge)
        let radio = (finalSize.width - smallFrame.width) / (largeFrame.width - smallFrame.width)
        let finalFrame = CGRect(x: (largeFrame.minX - smallFrame.minX) * radio + smallFrame.minX,
                                y: (largeFrame.minY - smallFrame.minY) * radio + smallFrame.minY,
                                width: finalSize.width,
                                height:finalSize.height)
        return finalFrame
    }
}
