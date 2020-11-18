//
//  MovieDetailBackdropTableViewCell.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

class MovieDetailBackdropTableViewCell: UITableViewCell {

    @IBOutlet weak var backdropImageView: AsyncImageView!
    @IBOutlet weak var posterImageView: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        gradientView.colors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(1)]
        selectionStyle = .none
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.init(top: 0, left: frame.width, bottom: 0, right: 0)
    }
}
