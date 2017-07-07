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

        navigationController?.delegate = transitionController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func ytz_pop() -> UIViewController? {
        navigationController?.delegate = YTZTransitionController.shared
        let popToVC = navigationController?.popViewController(animated: true)
        return popToVC
    }

    func ytz_present(_ viewController: UIViewController, frontDelegate: YTZTransitionFrontDelegate, backgroundDelegate: YTZTransitionBackgroundDelegate) {
        let transitionController = YTZTransitionController.shared
        transitionController.frontDelegate = frontDelegate
        transitionController.backgroundDelegate = backgroundDelegate
        transitionController.interactiveController.backwardType = .dismiss
        transitionController.interactiveController.frontVC = self

        viewController.transitioningDelegate = transitionController
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true, completion: nil)
    }
    
    func ytz_dismiss() {
        transitioningDelegate = YTZTransitionController.shared
        modalPresentationStyle = .fullScreen
        
        dismiss(animated: true, completion: nil)
    }
    
    func ytz_addZoomOutPanGestureRecognizer(in view: UIView) -> UIPanGestureRecognizer {
        let panGestureRecognizer: UIPanGestureRecognizer = YTZTransitionController.shared.interactiveController.panGestureRecognizer
        view.addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
}
