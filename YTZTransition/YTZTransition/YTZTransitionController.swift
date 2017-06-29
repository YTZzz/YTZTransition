//
//  YTZTransitionController.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZTransitionController: NSObject, UIGestureRecognizerDelegate {
    
    weak var delegate: YTZTransitionDelegate?
    static let shared = YTZTransitionController()
    var zoomView: UIView?
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
        return isDismissal ? 0.2 : 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let zoomView = self.zoomView else {
            transitionContext.completeTransition(true)
            return
        }
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        let zoomImageView = UIImageView(image: getImage(from: zoomView))
        zoomImageView.frame = fromVC.view.convert(zoomView.frame, to: fromVC.view)
        zoomImageView.contentMode = .scaleAspectFit
        zoomImageView.backgroundColor = zoomView.backgroundColor
        containerView.addSubview(zoomImageView)

        if isDismissal {
            zoomImageView.backgroundColor = fromVC.view.backgroundColor
            zoomView.isHidden = true
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            fromVC.view.removeFromSuperview()

            var zoomFinalFrame = CGRect(x: fromVC.view.bounds.minX, y: fromVC.view.bounds.minY, width: 0, height: 0)
            if let delegate = self.delegate {
                let placeHolderView = delegate.placeHolderView()
                zoomFinalFrame = toVC.view.convert(placeHolderView.frame, to: toVC.view)
            }
            UIView.animate(withDuration: duration, animations: {
                zoomImageView.frame = zoomFinalFrame
                fromVC.view.alpha = 0
            }, completion: {
                finished in
                if finished {
                    transitionContext.completeTransition(true)
                }
            })
        } else {
            zoomImageView.backgroundColor = toVC.view.backgroundColor
            let maxZoomScale: CGFloat = 1.1
            let originZoomScale = (1 - maxZoomScale) / 2
            let finialSize = toVC.view.bounds.size
            let maxZoomFrame = CGRect(x: finialSize.width * originZoomScale,
                                      y: finialSize.height * originZoomScale,
                                      width: finialSize.width * maxZoomScale,
                                      height: finialSize.height * maxZoomScale)
            let firstDurationRatio = 2.0 / 3.0
            zoomImageView.backgroundColor = .clear
            UIView.animate(withDuration: duration * firstDurationRatio, animations: {
                zoomImageView.frame = maxZoomFrame
                zoomImageView.backgroundColor = toVC.view.backgroundColor
            }, completion: {
                finished in
                if finished {
                    UIView.animate(withDuration: duration * (1 - firstDurationRatio), animations: {
                        zoomImageView.frame = UIScreen.main.bounds
                    }, completion: {
                        finished in
                        if finished {
                            containerView.addSubview(toVC.view)
                            zoomImageView.removeFromSuperview()
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
