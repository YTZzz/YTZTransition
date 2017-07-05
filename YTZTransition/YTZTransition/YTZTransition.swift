//
//  YTZTransition.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

extension UIViewController {
        
    func ytz_present(_ viewController: UIViewController) {
        guard
            let frontDelegate = viewController as? YTZTransitionFrontDelegate,
            let backgroundDelegate = self as? YTZTransitionBackgroundDelegate
            else {
                return
        }
        
        let transitionController = YTZTransitionController.shared
        transitionController.forwardAnimationType = .zoomIn
        let indexPath = frontDelegate.indexPathForDismiss()
        transitionController.backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        transitionController.frontTransitionView = frontDelegate.transitionViewForFrontVC()
        
        let originalPresentationStyle = modalPresentationStyle
        let originalTransitioningDelegate = transitioningDelegate
        
        transitioningDelegate = transitionController
        modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true, completion: {
            [weak self] in
            self?.modalPresentationStyle = originalPresentationStyle
            self?.transitioningDelegate = originalTransitioningDelegate
        })
    }
    func ytz_slideDismiss() {
        let transitionController = YTZTransitionController.shared
        transitionController.backwardAnimationType = .slide

        ytz_dismiss(transitionController: transitionController)
    }
    func ytz_zoomOutDismiss() {
        guard
            let frontDelegate = self as? YTZTransitionFrontDelegate,
            let backgroundDelegate = presentingViewController as? YTZTransitionBackgroundDelegate
        else {
            return
        }
        let transitionController = YTZTransitionController.shared
        transitionController.backwardAnimationType = .zoomOut
        let indexPath = frontDelegate.indexPathForDismiss()
        transitionController.backgroundTransitionView = backgroundDelegate.transitionViewForBackgroundVC(at: indexPath)
        transitionController.frontTransitionView = frontDelegate.transitionViewForFrontVC()
        
        ytz_dismiss(transitionController: transitionController)
    }
    
    private func ytz_dismiss(transitionController: YTZTransitionController) {
        let originalPresentationStyle = modalPresentationStyle
        let originalTransitioningDelegate = transitioningDelegate
        
        transitioningDelegate = transitionController
        modalPresentationStyle = .fullScreen
        
        dismiss(animated: true, completion: {
            [weak self] in
            self?.modalPresentationStyle = originalPresentationStyle
            self?.transitioningDelegate = originalTransitioningDelegate
        })
    }
    
    func ytz_addZoomOutDismissPanGestureRecognizer(in view: UIView) -> UIPanGestureRecognizer {
        let interactiveController = YTZTransitionController.shared.interactiveController
        interactiveController.frontVC = self
        let panGestureRecognizer: UIPanGestureRecognizer = interactiveController.dismissZoomOutPanGestureRecognizer
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
    
    func ytz_addSlideDismissPanGestureRecognizer(in view: UIView) -> UIPanGestureRecognizer {
        let interactiveController = YTZTransitionController.shared.interactiveController
        interactiveController.frontVC = self
        let panGestureRecognizer: UIPanGestureRecognizer = interactiveController.dismissSlidePanGestureRecognizer
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
}
