//
//  MainViewController.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, YTZTransitionDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorfulView: UIView!
    
    init() {
        super.init(nibName: "MainViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        let detailVC = DetailViewController(image: imageView.image!)
        ytz_present(detailVC, zoomView: colorfulView, delegate: self)
    }
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        let detailVC = DetailViewController(image: imageView.image!)
        ytz_present(detailVC, zoomView: imageView, delegate: self)
    }
    
    func placeHolderView() -> UIView {
        
        return imageView
    }
}
