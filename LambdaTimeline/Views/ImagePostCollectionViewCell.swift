//
//  ImagePostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostCollectionViewCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let post = post else { return }
    
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }

    func setupLabelBackgroundView() {
        let startColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        let endColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        labelBackgroundView.setupGradient(startColor: startColor, endColor: endColor)
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    var post: Post? {
        didSet {
            updateViews()
        }
    }

@IBOutlet weak var imageView: UIImageView!
@IBOutlet weak var titleLabel: UILabel!
@IBOutlet weak var authorLabel: UILabel!
@IBOutlet weak var labelBackgroundView: GradientView!

}
