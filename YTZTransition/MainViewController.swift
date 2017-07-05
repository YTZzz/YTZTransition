//
//  MainViewController.swift
//  YTZTransition
//
//  Created by Poseidon on 7/5/17.
//  Copyright © 2017 Taozhu Ye. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, YTZTransitionBackgroundDelegate {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    let cellId = "MainCollectionViewCell"
    
    init() {
        super.init(nibName: "MainViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: cellId, bundle: nil)
        mainCollectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImage(at index: Int) -> UIImage {
        return UIImage(named: "image\(index % 3 + 1).jpg")!
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainCollectionViewCell
        cell.imageView.image = getImage(at: indexPath.item)
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainCollectionViewCell
        detailVC.image = cell.imageView.image
        detailVC.indexPath = indexPath
        if segControl.selectedSegmentIndex == 0 {
            ytz_Push(viewController: detailVC)
        } else {
            ytz_present(detailVC)
        }
    }

    // MARK: - YTZTransitionBackgroundDelegate
    func transitionViewForBackgroundVC(at indexPath: IndexPath) -> UIView {
        mainCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        return cell
    }

}
