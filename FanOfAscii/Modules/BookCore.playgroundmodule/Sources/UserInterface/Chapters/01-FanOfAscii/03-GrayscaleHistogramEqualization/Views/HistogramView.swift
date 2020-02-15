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
        let pixelCount: UInt
    }

    var image: UIImage? {
        didSet {
            histogram = self.calculateHistogram()
            setNeedsDisplay()
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
        guard
            let histogram = self.histogram,
            let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let sampleCount = 256

        var lumLevels = [CGFloat](repeating: 0.0, count: sampleCount)
        for i in 0..<sampleCount {
            lumLevels[i] = 0.2126 * CGFloat(histogram.red[i]) + 0.7152 * CGFloat(histogram.green[i]) + 0.0722 * CGFloat(histogram.blue[i])
        }
        let redLevels: [CGFloat] = histogram.red.map({ CGFloat($0) })
        let greenLevels: [CGFloat] = histogram.green.map({ CGFloat($0) })
        let blueLevels: [CGFloat] = histogram.blue.map({ CGFloat($0) })

        drawHistogram(histogramVal: redLevels, color: .red, context: context)
        drawHistogram(histogramVal: greenLevels, color: .green, context: context)
        drawHistogram(histogramVal: blueLevels, color: .blue, context: context)
        drawHistogram(histogramVal: lumLevels, color: .white, context: context)
    }

    func drawHistogram(histogramVal: [CGFloat], color: UIColor, context: CGContext) {
        let size = self.bounds.size

        let sampleCount = histogramVal.count
        let pixelPerSample = size.width / CGFloat(sampleCount - 1)

        let levelMax = histogramVal.reduce(0.0) {
            max($0, $1)
        }
        let yVals: [CGFloat] = histogramVal.map {
            1.0 * size.height * (1.0 - CGFloat($0 / levelMax))
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        for i in 0..<sampleCount {
            let plotPoint = CGPoint(x: CGFloat(i) * pixelPerSample, y: yVals[i])
            print(yVals[i])
            path.addLine(to: plotPoint)
        }
        color.setStroke()
        context.setLineWidth(3.0)
        path.stroke()
    }

}

extension HistogramView {

    func calculateHistogram() -> Histogram? {
        guard let image = image,
              let cgImage = image.cgImage,
              let sourceBitmapData = cgImage.dataProvider?.data,
              let sourceBitmapPointer = UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(sourceBitmapData)) else {
            return nil
        }

        let sourceHeight = UInt(cgImage.height)
        let sourceWidth = UInt(cgImage.width)
        let sourceByteForRow = cgImage.bytesPerRow

        var sourceBuffer = vImage_Buffer(data: sourceBitmapPointer,
                                         height: sourceHeight,
                                         width: sourceWidth,
                                         rowBytes: sourceByteForRow)

        let pixelCount: UInt = sourceHeight * sourceWidth

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
        return Histogram(red: red, green: green, blue: blue, alpha: alpha, pixelCount: pixelCount)
    }

}
