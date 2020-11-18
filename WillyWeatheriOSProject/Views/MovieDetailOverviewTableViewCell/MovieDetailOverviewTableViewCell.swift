//
//  MovieDetailOverviewTableViewCell.swift
//  WillyWeatheriOSProject
//
//  Created by Hubilo Softech Private Limited on 18/11/20.
//

import UIKit

class MovieDetailOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        descriptionLabel.textColor = .lightText
        if #available(iOS 13, *) {
            contentView.backgroundColor = .systemBackground
        }
        else {
            contentView.backgroundColor = .black
        }
    }
}
