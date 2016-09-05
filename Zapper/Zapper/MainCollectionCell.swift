//
//  MainCollectionCell.swift
//  Zapper
//
//  Created by Niranjan Ravichandran on 04/09/16.
//  Copyright © 2016 nravichan. All rights reserved.
//

import UIKit

class MainCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var activitIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activitIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        activitIndicator.activityIndicatorViewStyle = .Gray
        activitIndicator.center = self.center
        self.addSubview(activitIndicator)
        activitIndicator.startAnimating()
        self.imageView.layer.cornerRadius = 4
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .ScaleAspectFill
    }

}
