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
    var selectedView: UIView!
    var imageDict = [IndexPath: UIImage]()
    
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
    
    func getImage(at indexPath: IndexPath) -> UIImage {
        if imageDict[indexPath] == nil {
            imageDict[indexPath] = UIImage(named: "image\(indexPath.item % 3 + 1).jpg")!
        }
        return imageDict[indexPath]!
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainCollectionViewCell
        cell.photoImageView.image = getImage(at: indexPath)
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.indexPath = indexPath
        detailVC.image = getImage(at: indexPath)
        if segControl.selectedSegmentIndex == 0 {
            ytz_Push(viewController: detailVC, frontDelegate: detailVC, backgroundDelegate: self)
        } else {
            ytz_present(detailVC, frontDelegate: detailVC, backgroundDelegate: self)
        }
    }

    // MARK: - YTZTransitionBackgroundDelegate
    func transitionViewForBackgroundVC(at indexPath: IndexPath) -> UIView {
        let cell = collectionView(mainCollectionView, cellForItemAt: indexPath) as! MainCollectionViewCell
        return cell.photoImageView
    }

}
