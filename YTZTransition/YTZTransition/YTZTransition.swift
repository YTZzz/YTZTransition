//
//  YTZTransition.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

extension UIViewController {
    func ytz_present(_ viewController: UIViewController, frontDelegate: YTZTransitionFrontDelegate?, backgroundDelegate: YTZTransitionBackgroundDelegate?) {
        
        let transitionController = YTZTransitionController.shared
        transitionController.isDismissal = false
        transitionController.frontDelegate = frontDelegate
        transitionController.backgroundDelegate = backgroundDelegate

        let originalPresentationStyle = viewController.modalPresentationStyle
        let originalTransitioningDelegate = viewController.transitioningDelegate
        
        viewController.transitioningDelegate = transitionController
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true, completion: {
            viewController.modalPresentationStyle = originalPresentationStyle
            viewController.transitioningDelegate = originalTransitioningDelegate
        })
    }
    
    func ytz_dismiss(frontTransitionView: UIView) {
        
        let transitionController = YTZTransitionController.shared
        transitionController.isDismissal = true
        transitionController.frontTransitionView = frontTransitionView

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
    
    func ytz_addInteractionDismissPanGesture() {
        view.addGestureRecognizer(YTZTransitionController.shared.dismissPanGestureRecognizer)
    }
}
