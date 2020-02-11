//
// Created by Bunny Wong on 2020/2/11.
//

import UIKit

class ShowcaseImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            roundCornersForAspectFit()
        }
    }
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            roundCornersForAspectFit()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCornersForAspectFit()
    }

    func roundCornersForAspectFit() {
        if let image = self.image {
            let radius = self.cornerRadius

            let boundsScale = self.bounds.size.width / self.bounds.size.height
            let imageScale = image.size.width / image.size.height

            var drawingRect: CGRect = self.bounds

            if boundsScale > imageScale {
                drawingRect.size.width = drawingRect.size.height * imageScale
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

}

