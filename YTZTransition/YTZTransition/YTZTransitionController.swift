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

enum YTZTransitionBackwardType {
    case dismiss
    case pop
}

class YTZTransitionController: NSObject, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables
    static let shared = YTZTransitionController()
    
    var interactiveController = YTZPercentDrivenInteractiveController()
    
    
    // MARK: - Init
    private override init() {
        super.init()
    }

    // MARK: - UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = YTZForwardAnimationController()
        return animationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = YTZBackwardAnimationController()
        animationController.frontVC = dismissed
        animationController.backwardType = .dismiss
        return animationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveController.isInteraction {
            if let animationController = animator as? YTZBackwardAnimationController {
                interactiveController.backwardAnimationController = animationController
            }
            return interactiveController
        }
        return nil
    }

    // MARK: - UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return  YTZForwardAnimationController()
        }
        if operation == .pop {
            let animationController = YTZBackwardAnimationController()
            animationController.frontVC = fromVC
            animationController.backwardType = .pop
            return animationController
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveController.isInteraction {
            if let animationController = animationController as? YTZBackwardAnimationController {
                interactiveController.backwardAnimationController = animationController
            }
            return interactiveController
        }
        return nil
    }


    // MARK: - Class func
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
