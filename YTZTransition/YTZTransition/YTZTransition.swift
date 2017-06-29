//
//  YTZTransition.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

protocol YTZTransitionDelegate: class {
    func placeHolderView() -> UIView
}

extension UIViewController {
    func ytz_present(_ viewController: UIViewController, zoomView: UIView, delegate: YTZTransitionDelegate?) {
        
        let transitionController = YTZTransitionController.shared
        transitionController.isDismissal = false
        transitionController.zoomView = zoomView
        transitionController.delegate = delegate
        
        let originalPresentationStyle = viewController.modalPresentationStyle
        let originalTransitioningDelegate = viewController.transitioningDelegate
        
        viewController.transitioningDelegate = transitionController
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true, completion: {
            viewController.modalPresentationStyle = originalPresentationStyle
            viewController.transitioningDelegate = originalTransitioningDelegate
        })
    }
    
    func ytz_dismiss(zoomView: UIView) {
        
        let transitionController = YTZTransitionController.shared
        transitionController.isDismissal = true
        transitionController.zoomView = zoomView

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
