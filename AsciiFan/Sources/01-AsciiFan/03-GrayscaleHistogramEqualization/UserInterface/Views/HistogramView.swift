//
// Created by Bunny Wong on 2020/2/14.
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
              let sourceFormat = vImage_CGImageFormat(cgImage: cgImage),
              let destinationFormat = vImage_CGImageFormat(
                  bitsPerComponent: 8,
                  bitsPerPixel: 32,
                  colorSpace: CGColorSpaceCreateDeviceRGB(),
                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
              ) else {
            return nil
        }
        guard var sourceBuffer = try? vImage_Buffer(cgImage: cgImage, format: sourceFormat),
              var destinationBuffer = try? vImage_Buffer(
                  width: Int(sourceBuffer.width),
                  height: Int(sourceBuffer.height),
                  bitsPerPixel: sourceFormat.bitsPerPixel
              ) else {
            return nil
        }
        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        do {
            let toARGBConverter = try vImageConverter.make(
                sourceFormat: sourceFormat,
                destinationFormat: destinationFormat
            );
            try toARGBConverter.convert(source: sourceBuffer, destination: &destinationBuffer)
        } catch {
            return nil
        }

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
        if error != vImage.Error.noError.rawValue {
            return nil
        }
        return Histogram(red: red, green: green, blue: blue, alpha: alpha)
    }

}
