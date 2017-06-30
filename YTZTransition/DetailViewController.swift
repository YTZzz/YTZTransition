//
//  DetailViewController.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, YTZTransitionFrontDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        ytz_addInteractionDismissPanGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    init() {
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
    
    @IBAction func touchCloseButton(_ sender: UIButton) {
//        dismiss(animated: true, completion: nil)
        ytz_dismiss()
    }
    
    func transitionViewForFrontVC() -> UIView {
        return imageView
    }
}
