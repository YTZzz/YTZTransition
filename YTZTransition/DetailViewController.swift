//
//  DetailViewController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/5/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, YTZTransitionFrontDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    var indexPath: IndexPath!
    
    init() {
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        imageView.addGestureRecognizer(tapGesture)
        let panGesture = ytz_addZoomOutPanGestureRecognizer(in: imageView)
//        panGesture.require(toFail: tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTapGesture(_ tagGesture: UITapGestureRecognizer) {
        if navigationController == nil {
            ytz_dismiss()
        } else {
            _ = ytz_pop()
        }
    }
    
    // MARK: - YTZTransitionFrontDelegate
    func transitionViewForFrontVC() -> UIView {
        return imageView
    }
    
    func indexPathForDismiss() -> IndexPath {
        return indexPath
    }
}
