//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
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

    private var drawingRect: CGRect? {
        get {
            guard let image = image else {
                return nil
            }
            let boundsRatio = self.bounds.size.width / self.bounds.size.height
            let imageRatio = image.size.width / image.size.height

            var drawingRect: CGRect = self.bounds
            if boundsRatio > imageRatio {
                drawingRect.size.width = drawingRect.size.height * imageRatio
                drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageRatio
                drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
            }
            return drawingRect
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundCornersForAspectFit()
    }

    func pointInImageFor(point: CGPoint) -> CGPoint? {
        guard let imageSize = self.image?.size,
              let drawingRect = self.drawingRect,
              drawingRect.contains(point) else {
            return nil
        }

        let pointInScaledImage = CGPoint(x: point.x - drawingRect.minX, y: point.y - drawingRect.minY)
        let pointInImage = CGPoint(x: pointInScaledImage.x * (imageSize.width / drawingRect.width),
                                   y: pointInScaledImage.y * (imageSize.height / drawingRect.height))
        return pointInImage
    }

    func roundCornersForAspectFit() {
        guard let drawingRect = self.drawingRect else {
            return
        }
        let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: cornerRadius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

}

