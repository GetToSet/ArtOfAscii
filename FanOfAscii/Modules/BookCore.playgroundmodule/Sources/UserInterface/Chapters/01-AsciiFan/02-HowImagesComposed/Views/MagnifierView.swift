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
            if let provider = image.cgImage?.dataProvider {
                imageRawData = provider.data
            }
            self.setNeedsDisplay()
        }
    }

    private var imageRawData: CFData?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
        self.backgroundColor = .black

        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
        self.layer.borderWidth = 8.0
        self.layer.borderColor = UIColor.white.cgColor
    }

    override func draw(_ rect: CGRect) {
        guard
            let center = magnificationCenter,
            let rawData = imageRawData else {
            return
        }

        let croppingRect = CGRect(origin: center, size: CGSize(width: samplePixels, height: samplePixels))

        if let context = UIGraphicsGetCurrentContext() {
            let pixelSize = Int(min(self.bounds.width / CGFloat(samplePixels), self.bounds.height / CGFloat(samplePixels)))

            for y in 0..<samplePixels {
                for x in 0..<samplePixels {
                    let ix = x + Int(croppingRect.minX)
                    let iy = y + Int(croppingRect.minY)
                    let pixelColor: UIColor = pixelColorAt(x: ix, y: iy, rawData: rawData, size: image.size) ?? .black

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

    func pixelColorAt(x: Int, y: Int, rawData: CFData, size: CGSize) -> UIColor? {
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }

        let data = CFDataGetBytePtr(rawData)

        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

}


