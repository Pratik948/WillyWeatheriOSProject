//
//  MovieGridCollectionViewCell.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

class MovieGridCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        gradientView.colors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(1)]
    }

}
