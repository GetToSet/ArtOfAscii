//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/14.
//

import UIKit
import Accelerate

class HistogramView: UIView {

    struct Histogram {
        let red: [UInt]
        let green: [UInt]
        let blue: [UInt]
        let alpha: [UInt]
    }

    var image: UIImage? {
        didSet {
            histogram = self.calculateHistogram()
        }
    }

    private var histogram: Histogram?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 4.0
    }

    override func draw(_ rect: CGRect) {
        // Draw rects with the histogram
        
    }

    func calculateHistogram() -> Histogram? {
        guard let image = image,
              let cgImage = image.cgImage,
              let sourceBitmapData = cgImage.dataProvider?.data,
              let sourceBitmapPointer = UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(sourceBitmapData)) else {
            return nil
        }

        let sourceHeight = Int(cgImage.height)
        let sourceWidth = Int(cgImage.width)
        let sourceByteForRow = cgImage.bytesPerRow
        
        var sourceBuffer = vImage_Buffer(data: sourceBitmapPointer,
                                         height: UInt(sourceHeight),
                                         width:  UInt(sourceWidth),
                                         rowBytes: sourceByteForRow)

        var alpha = [UInt](repeating: 0, count: 256)
        var red = [UInt](repeating: 0, count: 256)
        var green = [UInt](repeating: 0, count: 256)
        var blue = [UInt](repeating: 0, count: 256)

        let alphaPtr = UnsafeMutablePointer<vImagePixelCount>(&alpha) as UnsafeMutablePointer<vImagePixelCount>?
        let redPtr = UnsafeMutablePointer<vImagePixelCount>(&red) as UnsafeMutablePointer<vImagePixelCount>?
        let greenPtr = UnsafeMutablePointer<vImagePixelCount>(&green) as UnsafeMutablePointer<vImagePixelCount>?
        let bluePtr = UnsafeMutablePointer<vImagePixelCount>(&blue) as UnsafeMutablePointer<vImagePixelCount>?

        var rgba = [redPtr, greenPtr, bluePtr, alphaPtr]

        let histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>?>(&rgba)

        let error = vImageHistogramCalculation_ARGB8888(&sourceBuffer, histogram, UInt32(kvImageNoFlags))
        if error != kvImageNoError {
            return nil
        }
        return Histogram(red: red, green: green, blue: blue, alpha: alpha)
    }

}
