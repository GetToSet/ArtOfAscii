//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/14.
//

import UIKit
import Accelerate

class HistogramView: UIView {

    enum RenderMode {
        case brightness, rgb
    }

    var image: UIImage? {
        didSet {
            calculateHistogram()
            setNeedsDisplay()
        }
    }

    private var rgbaHistogram: RgbaHistogram?
    private var brightnessHistogram: [UInt]?

    var renderingMode: RenderMode = .brightness {
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
        case .brightness:
            guard let brightnessHistogram = self.brightnessHistogram else {
                break
            }
            drawHistogram(histogramVal: brightnessHistogram,
                    color: .white,
                    fractionStart: 0.0,
                    fractionEnd: 1.0,
                    context: context)
        case .rgb:
            guard let histogram = self.rgbaHistogram else {
                break
            }
            drawHistogram(histogramVal: histogram.red,
                    color: .red,
                    fractionStart: 0.0,
                    fractionEnd: 1.0 / 3.0,
                    context: context)
            drawHistogram(histogramVal: histogram.green,
                    color: .green,
                    fractionStart: 1.0 / 3.0,
                    fractionEnd: 2.0 / 3.0,
                    context: context)
            drawHistogram(histogramVal: histogram.blue,
                    color: .blue,
                    fractionStart: 2.0 / 3.0,
                    fractionEnd: 1.0,
                    context: context)
        }
    }

    private func calculateHistogram() {
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        rgbaHistogram = rawImage.calculateRgbHistogram()
        brightnessHistogram = rawImage.calculateBrightnessHistogram()
    }

    private func drawHistogram(histogramVal: [UInt], color: UIColor, fractionStart: CGFloat, fractionEnd: CGFloat, context: CGContext) {
        let sampleCount = histogramVal.count

        let size = self.bounds.size
        let padding = self.layer.borderWidth + 2.0

        let levelMax = CGFloat(histogramVal.reduce(0, ({ max($0, $1) })))
        let yVals: [CGFloat] = histogramVal.map {
            padding + (size.height - 2 * padding) * (1.0 - CGFloat($0) / levelMax)
        }

        let path = UIBezierPath()

        let availableWidth = size.width - 2 * padding
        let xStart = padding + availableWidth * fractionStart
        let xEnd = padding + availableWidth * fractionEnd

        path.move(to: CGPoint(x: xStart, y: size.height))
        for i in 0..<sampleCount {
            let xVal = xStart + (xEnd - xStart) / CGFloat(sampleCount - 1) * CGFloat(i)
            let plotPoint = CGPoint(x: xVal, y: yVals[i])
            path.addLine(to: plotPoint)
        }
        color.setStroke()
        context.setLineWidth(3.0)
        path.stroke()

        path.addLine(to: CGPoint(x: xEnd, y: size.height))
        path.close()

        color.withAlphaComponent(0.2).setFill()
        path.fill()
    }

}
