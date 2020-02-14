//
// Created by Bunny Wong on 2020/2/14.
//

import UIKit

class HistogramView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 4.0
    }

}
