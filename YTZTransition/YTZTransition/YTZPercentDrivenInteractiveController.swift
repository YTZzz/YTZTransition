//
//  YTZPercentDrivenInteractiveController.swift
//  YTZTransition
//
//  Created by Sodapig on 01/07/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class YTZPercentDrivenInteractiveController: UIPercentDrivenInteractiveTransition {
    
    var backgroundZoomView: UIView?
    var finalFrame: CGRect?
    var zoomView: UIView?
    
    override func finish() {
        guard let backgroundZoomView = self.backgroundZoomView, let zoomView = self.zoomView, let finalFrame = self.finalFrame else {
            super.finish()
            return
        }
        super.finish()
        let leftDuration = Double((1 - percentComplete) * duration)
        UIView.animate(withDuration: leftDuration, delay: 0, options: .curveEaseInOut, animations: {
            zoomView.frame = finalFrame
        }, completion: {
            finished in
            if finished {
                backgroundZoomView.isHidden = false
                zoomView.isHidden = true
            }
        })
    }
}
