//
//  YTZTransition.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func ytz_Push(viewController: UIViewController, frontDelegate: YTZTransitionFrontDelegate, backgroundDelegate: YTZTransitionBackgroundDelegate) {
        let transitionController = YTZTransitionController.shared
        transitionController.frontDelegate = frontDelegate
        transitionController.backgroundDelegate = backgroundDelegate
        transitionController.interactiveController.backwardType = .pop
        transitionController.interactiveController.frontVC = self

        let originalNavigationDelegate = navigationController?.delegate
        navigationController?.delegate = transitionController
        navigationController?.pushViewController(viewController, animated: true)
        navigationController?.delegate = originalNavigationDelegate
    }
    
    func ytz_pop() -> UIViewController? {
        let originalNavigationDelegate = navigationController?.delegate
        navigationController?.delegate = YTZTransitionController.shared
        let popToVC = navigationController?.popViewController(animated: true)
        navigationController?.delegate = originalNavigationDelegate
        return popToVC
    }

    func ytz_present(_ viewController: UIViewController, frontDelegate: YTZTransitionFrontDelegate, backgroundDelegate: YTZTransitionBackgroundDelegate) {
        let transitionController = YTZTransitionController.shared
        transitionController.frontDelegate = frontDelegate
        transitionController.backgroundDelegate = backgroundDelegate
        transitionController.interactiveController.backwardType = .dismiss
        transitionController.interactiveController.frontVC = self

        let originalPresentationStyle = viewController.modalPresentationStyle
        let originalTransitioningDelegate = viewController.transitioningDelegate
        
        viewController.transitioningDelegate = transitionController
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true, completion: {
            viewController.modalPresentationStyle = originalPresentationStyle
            viewController.transitioningDelegate = originalTransitioningDelegate
        })
    }
    
    func ytz_dismiss() {
        let transitionController = YTZTransitionController.shared
        
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
    
    func ytz_addZoomOutPanGestureRecognizer(in view: UIView) -> UIPanGestureRecognizer {
        let panGestureRecognizer: UIPanGestureRecognizer = YTZTransitionController.shared.interactiveController.panGestureRecognizer
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
}
