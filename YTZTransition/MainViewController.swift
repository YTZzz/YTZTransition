//
//  MainViewController.swift
//  YTZTransition
//
//  Created by Sodapig on 29/06/2017.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, YTZTransitionBackgroundDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    var selectedView: UIView!
    
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
    
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        let detailVC = DetailViewController(image: imageView.image!)
        selectedView = imageView
        ytz_present(detailVC, frontDelegate: detailVC, backgroundDelegate: self)
    }
    
    @IBAction func tapSecondImageView(_ sender: Any) {
        let detailVC = DetailViewController(image: secondImageView.image!)
        selectedView = secondImageView
        ytz_present(detailVC, frontDelegate: detailVC, backgroundDelegate: self)
    }
    
    func transitionViewForBackgroundVC(at indexPath: IndexPath) -> UIView {
        return selectedView
    }
}
