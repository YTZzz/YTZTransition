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
    var frontTransitionView: UIView?
    var backgroundTransitionView: UIView?
    var isDismissal = false
    var dismissPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
    
    private override init() {
        super.init()
        dismissPanGestureRecognizer.delegate = self
    }
    
    func handleDismissPanGestureRecognizer(_ panGestureRecognizer: UIPanGestureRecognizer) {
//        switch panGestureRecognizer.state {
//        case .began:
//            
//        case .changed:
//        case .ended:
//        default:
//            break
//        }
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
        return dismissPanGestureRecognizer.state == .began ? self : nil
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
            
            guard let backgroundDelegate = self.backgroundDelegate, let frontTransitionView = self.frontTransitionView else {
                transitionContext.completeTransition(true)
                return
            }
            let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC()
            
            let image = getImage(from: frontTransitionView)
            let zoomImageView = UIImageView(image: image)
            zoomImageView.frame = getAsceptFitFrame(image: image, frame: fromVC.view.convert(frontTransitionView.frame, to: fromVC.view))
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            zoomImageView.backgroundColor = fromVC.view.backgroundColor
            containerView.addSubview(zoomImageView)
            
            frontTransitionView.isHidden = true
            
            let zoomFinalFrame = toVC.view.convert(backgroundTransitionView.frame, to: toVC.view)
            frontTransitionView.isHidden = true
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            fromVC.view.backgroundColor = .white

            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut, .preferredFramesPerSecond60], animations: {
                zoomImageView.frame = zoomFinalFrame
                fromVC.view.alpha = 0
            }, completion: {
                finished in
                if finished {
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            })

        } else {
            
            guard let frontDelegate = self.frontDelegate, let backgroundDelegate = self.backgroundDelegate else {
                transitionContext.completeTransition(true)
                return
            }
            let frontTransitionView = frontDelegate.transitionViewForFrontVC()
            let backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC()
            
            let image = getImage(from: backgroundTransitionView)
            let zoomImageView = UIImageView(image: image)
            let zoomFinalFrame = getAsceptFitFrame(image: image, frame: toVC.view.convert(frontTransitionView.frame, to: toVC.view))
            zoomImageView.frame = fromVC.view.convert(backgroundTransitionView.frame, to: fromVC.view)
            zoomImageView.contentMode = .scaleAspectFit
            zoomImageView.backgroundColor = backgroundTransitionView.backgroundColor
            containerView.addSubview(zoomImageView)

            let maxZoomScale: CGFloat = 1.1
//            let originPointZoomScale = (1 - maxZoomScale) / 2
//            let finialSize = frontTransitionViewFrameInFromView.size
//            let maxZoomFrame = CGRect(x: finialSize.width * originPointZoomScale + frontTransitionViewFrameInFromView.minX,
//                                      y: finialSize.height * originPointZoomScale + frontTransitionViewFrameInFromView.minY,
//                                      width: finialSize.width * maxZoomScale,
//                                      height: finialSize.height * maxZoomScale)
            
            let maxZoomFrame = getProjectionFrame(smallFrame: zoomImageView.frame, largeFrame: zoomFinalFrame, radioFinalDividLarge: maxZoomScale)
            
            let firstDurationRatio = 14.0 / 24.0

            frontTransitionView.isHidden = true
            toVC.view.alpha = 0
            containerView.insertSubview(toVC.view, belowSubview: zoomImageView)
            
            UIView.animate(withDuration: duration * firstDurationRatio, delay: 0, options: [.curveEaseInOut, .preferredFramesPerSecond60], animations: {
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
extension YTZTransitionController: UIViewControllerInteractiveTransitioning {
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
    }
}

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

        var smallFillFrame = CGRect.zero // change small size to aspect fill large size
        let largeWDividH = largeFrame.width / largeFrame.height
        let smallWDividH = smallFrame.width / smallFrame.height
        if largeWDividH >= smallWDividH {
            let width = smallFrame.height * largeWDividH
            smallFillFrame = CGRect(x: smallFrame.midX - width / 2, y: smallFrame.minY, width: width, height: smallFrame.height)
        } else {
            let height = smallFrame.width / largeWDividH
            smallFillFrame = CGRect(x: smallFrame.minX, y: smallFrame.midY - height / 2, width: smallFrame.width, height: height)
        }
        
        let finalSize = CGSize(width: largeFrame.width * radioFinalDividLarge, height: largeFrame.height * radioFinalDividLarge)
        let radio = (finalSize.width - smallFillFrame.width) / (largeFrame.width - smallFillFrame.width)
        let finalFrame = CGRect(x: (largeFrame.minX - smallFillFrame.minX) * radio + smallFillFrame.minX,
                                y: (largeFrame.minY - smallFillFrame.minY) * radio + smallFillFrame.minY,
                                width: finalSize.width,
                                height:finalSize.height)
        return finalFrame
    }
}
