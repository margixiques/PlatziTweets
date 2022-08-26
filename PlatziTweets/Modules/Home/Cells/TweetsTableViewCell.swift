//
//  TweetsTableViewCell.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 18/08/22.
//

import UIKit
import Kingfisher

class TweetsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellWith(post: Tweet) {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        tweetLabel.text = post.text
        
        tweetImageView.isHidden = !post.hasImage
        videoButton.isHidden = !post.hasImage
        
        if post.hasImage {
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        }
    }

}
