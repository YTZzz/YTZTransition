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
    func indexPathForDismiss() -> IndexPath
}
protocol YTZTransitionBackgroundDelegate: class {
    func transitionViewForBackgroundVC(at indexPath: IndexPath) -> UIView
}

enum YTZTransitionForwardAnimationType {
    case zoomIn
}

enum YTZTransitionBackwardAnimationType {
    case zoomOut
    case slide
}

class YTZTransitionController: NSObject, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    static let shared = YTZTransitionController()
    
    var backgroundTransitionView: UIView!
    var frontTransitionView: UIView!
    var forwardAnimationType: YTZTransitionForwardAnimationType = .zoomIn
    var backwardAnimationType: YTZTransitionBackwardAnimationType = .zoomOut

    var frontVC: UIViewController?
    var isDismissal = false
    var dismissZoomOutPanGestureRecognizer: UIPanGestureRecognizer!
    var dismissSlidePanGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var zoomImageView: UIImageView?
    
    fileprivate var isInteraction = false
    fileprivate var interactiveController = YTZPercentDrivenInteractiveController()
    fileprivate var startInteractionPoint = CGPoint.zero
    fileprivate var interactionLastTouchPoint = CGPoint.zero
    fileprivate var zoomImageViewStartInteractionFrame = CGRect.zero
    
    
    
    // MARK: - Init
    private override init() {
        super.init()
        dismissZoomOutPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
        dismissZoomOutPanGestureRecognizer.delegate = self
        dismissSlidePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPanGestureRecognizer(_:)))
        dismissSlidePanGestureRecognizer.delegate = self
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
                if progress > 0.15 && panGestureRecognizer.velocity(in: panGestureRecognizer.view!).y > -5 {
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
        } else if panGestureRecognizer == dismissSlidePanGestureRecognizer {
            
        }
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
        return false
    }
}

extension YTZTransitionController: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return  YTZForwardAnimationController(backgroundTransitionView: backgroundTransitionView, frontTransitionView: frontTransitionView)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if backwardAnimationType == .slide {
            return YTZBackwardAnimationController()
        }
        return YTZBackwardAnimationController(backgroundTransitionView: backgroundTransitionView, frontTransitionView: frontTransitionView)
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteraction ? interactiveController : nil
    }
    
    // MARK: - UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return  YTZForwardAnimationController(backgroundTransitionView: backgroundTransitionView, frontTransitionView: frontTransitionView)
        }
        if operation == .pop {
            if backwardAnimationType == .slide {
                return YTZBackwardAnimationController()
            }
            return YTZBackwardAnimationController(backgroundTransitionView: backgroundTransitionView, frontTransitionView: frontTransitionView)
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return isInteraction ? interactiveController : nil
    }
}

// Class func
extension YTZTransitionController {
    
    class func getImage(from View: UIView) -> UIImage {
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

    class func getAsceptFitFrame(image: UIImage, frame: CGRect) -> CGRect {
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
    
    class func getProjectionFrame(firstFrame: CGRect, secondFrame: CGRect, radioThirdDividSecond: CGFloat) -> CGRect {
        let finalSize = CGSize(width: secondFrame.width * radioThirdDividSecond, height: secondFrame.height * radioThirdDividSecond)
        let radio = (finalSize.width - firstFrame.width) / (secondFrame.width - firstFrame.width)
        let finalFrame = CGRect(x: (secondFrame.minX - firstFrame.minX) * radio + firstFrame.minX,
                                y: (secondFrame.minY - firstFrame.minY) * radio + firstFrame.minY,
                                width: finalSize.width,
                                height:finalSize.height)
        return finalFrame
    }
}
