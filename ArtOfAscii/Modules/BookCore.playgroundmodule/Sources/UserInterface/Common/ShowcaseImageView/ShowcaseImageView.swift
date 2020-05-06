//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import UIKit

class ShowcaseImageView: UIImageView {

    override var image: UIImage? {
        didSet {
            makeRoundedCorner()
        }
    }

    var cornerRadius: CGFloat = 0.0 {
        didSet {
            makeRoundedCorner()
        }
    }

    override var contentMode: ContentMode {
        didSet {
            makeRoundedCorner()
        }
    }

    private var drawingRect: CGRect? {
        guard let image = image else {
            return nil
        }
        switch contentMode {
        case .scaleAspectFit:
            let boundsRatio = bounds.size.width / bounds.size.height
            let imageRatio = image.size.width / image.size.height

            var drawingRect = bounds
            if boundsRatio > imageRatio {
                drawingRect.size.width = drawingRect.size.height * imageRatio
                drawingRect.origin.x = (bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageRatio
                drawingRect.origin.y = (bounds.size.height - drawingRect.size.height) / 2
            }
            return drawingRect
        case .center:
            var drawingRect = bounds
            if image.size.width < bounds.size.width {
                drawingRect.size.width = image.size.width
                drawingRect.origin.x = (bounds.size.width - drawingRect.size.width) / 2
            }
            if image.size.height < bounds.size.height {
                drawingRect.size.height = image.size.height
                drawingRect.origin.y = (bounds.size.height - drawingRect.size.height) / 2
            }
            return drawingRect
        default:
            fatalError("Content mode \(contentMode) is not supported, please choose .scaleAspectFit or .center")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeRoundedCorner()
    }

    func pointInImageFor(point: CGPoint) -> CGPoint? {
        guard let imageSize = image?.size,
              let drawingRect = drawingRect else {
            return nil
        }

        let pointInScaledImage = CGPoint(
                x: point.x - drawingRect.minX,
                y: point.y - drawingRect.minY)
        let pointInImage = CGPoint(
                x: pointInScaledImage.x * (imageSize.width / drawingRect.width),
                y: pointInScaledImage.y * (imageSize.height / drawingRect.height))
        return pointInImage
    }

    func makeRoundedCorner() {
        guard let drawingRect = drawingRect else {
            return
        }
        let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: cornerRadius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

}
