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

    var image: UIImage? {
        didSet {
            calculateHistogram()
            setNeedsDisplay()
        }
    }

    private var rgbaHistogram: RgbaHistogram?
    private var luminanceHistogram: [UInt]?

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
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        switch renderingMode {
        case .luminance:
            guard let luminanceHistogram = self.luminanceHistogram else {
                break
            }
            drawHistogram(histogramVal: luminanceHistogram, color: .white, context: context)
        case .rgb:
            guard let histogram = self.rgbaHistogram else {
                break
            }
            drawHistogram(histogramVal: histogram.red, color: .red, context: context)
            drawHistogram(histogramVal: histogram.green, color: .green, context: context)
            drawHistogram(histogramVal: histogram.blue, color: .blue, context: context)
        }
    }

    private func calculateHistogram() {
        let rawImage = RawImage(uiImage: image)
        rgbaHistogram = rawImage?.calculateRgbHistogram()
        luminanceHistogram = rawImage?.calculateLuminanceHistogram()
    }

    private func drawHistogram(histogramVal: [UInt], color: UIColor, context: CGContext) {
        let sampleCount = histogramVal.count

        let size = self.bounds.size
        let padding = self.layer.borderWidth + 2.0

        let pixelPerSample = size.width / CGFloat(sampleCount - 1)

        let levelMax = CGFloat(histogramVal.reduce(0, ({ max($0, $1) })))
        let yVals: [CGFloat] = histogramVal.map {
            padding + (size.height - 2 * padding) * (1.0 - CGFloat($0) / levelMax)
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
