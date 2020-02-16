//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/14.
//

import UIKit
import Accelerate

class HistogramView: UIView {

    enum RenderMode {
        case luminance, rgb
    }

    struct Histogram {
        static let length = 256

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

    var renderingMode: RenderMode = .luminance {
        didSet {
            setNeedsDisplay()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 4.0
    }

    override func draw(_ rect: CGRect) {
        guard let histogram = self.histogram,
              let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let sampleCount = Histogram.length

        var lumLevels = [Float](repeating: 0.0, count: sampleCount)
        for i in 0..<sampleCount {
            lumLevels[i] = 0.2126 * Float(histogram.red[i]) + 0.7152 * Float(histogram.green[i]) + 0.0722 * Float(histogram.blue[i])
        }

        switch renderingMode {
        case .luminance:
            drawHistogram(histogramVal: lumLevels, color: .white, context: context)
        case .rgb:
            drawHistogram(histogramVal: histogram.red.map({ Float($0) }), color: .red, context: context)
            drawHistogram(histogramVal: histogram.green.map({ Float($0) }), color: .green, context: context)
            drawHistogram(histogramVal: histogram.blue.map({ Float($0) }), color: .blue, context: context)
        }
    }

    func drawHistogram(histogramVal: [Float], color: UIColor, context: CGContext) {
        guard histogramVal.count == Histogram.length else {
            return
        }

        let sampleCount = histogramVal.count

        let size = self.bounds.size
        let padding = self.layer.borderWidth + 2.0

        let pixelPerSample = size.width / CGFloat(sampleCount - 1)

        let levelMax = histogramVal.reduce(0.0, ({ max($0, $1) }))
        let yVals: [CGFloat] = histogramVal.map {
            padding + (size.height - 2 * padding) * (1.0 - CGFloat($0 / levelMax))
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: size.height))
        for i in 0..<sampleCount {
            let plotPoint = CGPoint(x: CGFloat(i) * pixelPerSample, y: yVals[i])
            path.addLine(to: plotPoint)
        }
        color.setStroke()
        context.setLineWidth(3.0)
        path.stroke()

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.close()

        color.withAlphaComponent(0.2).setFill()
        path.fill()
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

        var alpha = [UInt](repeating: 0, count: Histogram.length)
        var red = [UInt](repeating: 0, count: Histogram.length)
        var green = [UInt](repeating: 0, count: Histogram.length)
        var blue = [UInt](repeating: 0, count: Histogram.length)

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
