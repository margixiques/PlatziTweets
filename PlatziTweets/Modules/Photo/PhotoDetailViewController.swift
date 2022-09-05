//
//  PhotoDetailViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 2/09/22.
//

import UIKit
import Kingfisher

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imageURL = imageURL else { return }
        self.imageView.kf.setImage(with: URL(string: imageURL))
    }
}



