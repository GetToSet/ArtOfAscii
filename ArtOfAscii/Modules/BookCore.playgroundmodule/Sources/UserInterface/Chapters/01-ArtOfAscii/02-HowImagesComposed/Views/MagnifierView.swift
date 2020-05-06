//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/12.
//

import UIKit

class MagnifierView: UIView {

    var samplePixels = 9

    var magnificationCenter: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var image: UIImage = UIImage() {
        didSet {
            rawImage = RawImage(uiImage: image)
            self.setNeedsDisplay()
        }
    }

    private var rawImage: RawImage?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
        self.backgroundColor = .black

        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
        self.layer.borderWidth = 8.0
        self.layer.borderColor = UIColor.white.cgColor
    }

    override func draw(_ rect: CGRect) {
        guard let center = magnificationCenter,
              let rawImage = rawImage,
              let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let samplingRect = CGRect(origin: center, size: CGSize(width: samplePixels, height: samplePixels))

        let pixelSize = Int(min(self.bounds.width / CGFloat(samplePixels), self.bounds.height / CGFloat(samplePixels)))

        for y in 0..<samplePixels {
            for x in 0..<samplePixels {
                let ix = x + Int(samplingRect.minX)
                let iy = y + Int(samplingRect.minY)

                var pixel = rawImage.pixelAt(x: ix, y: iy)
                let pixelColor: UIColor = pixel?.uiColor ?? .black

                context.setFillColor(pixelColor.cgColor)
                context.fill(CGRect(x: x * pixelSize, y: y * pixelSize, width: pixelSize, height: pixelSize))
            }
        }

        context.setStrokeColor(UIColor.lightGray.cgColor)
        for i in 0..<samplePixels {
            context.stroke(CGRect(x: i * pixelSize, y: 0, width: pixelSize, height: pixelSize * samplePixels))
            context.stroke(CGRect(x: 0, y: i * pixelSize, width: pixelSize * samplePixels, height: pixelSize))
        }

        let mid = samplePixels / 2
        context.setStrokeColor(UIColor.white.cgColor)
        context.stroke(CGRect(x: mid * pixelSize, y: 0, width: pixelSize, height: pixelSize * samplePixels))
        context.stroke(CGRect(x: 0, y: mid * pixelSize, width: pixelSize * samplePixels, height: pixelSize))
    }

}
