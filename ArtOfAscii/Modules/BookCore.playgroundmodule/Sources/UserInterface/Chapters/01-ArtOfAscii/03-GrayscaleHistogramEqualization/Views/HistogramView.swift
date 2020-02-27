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

    var shouldDrawCumulativePixelFrequency: Bool = false {
        didSet {
            if renderingMode == .brightness {
                setNeedsDisplay()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
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
            if shouldDrawCumulativePixelFrequency {
                drawCumulativePixelFrequency(histogramVal: brightnessHistogram,
                        color: UIColor.States.highlight,
                        fractionStart: 0.0,
                        fractionEnd: 1.0,
                        context: context)
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

    private func drawCumulativePixelFrequency(histogramVal: [UInt], color: UIColor, fractionStart: CGFloat, fractionEnd: CGFloat, context: CGContext) {
        var pixelCumulative: UInt = 0
        let pixelCumulativeVals: [CGFloat] = histogramVal.map {
            pixelCumulative += $0
            return CGFloat(pixelCumulative)
        }
        plotGraph(values: pixelCumulativeVals, color: color, fractionStart: fractionStart, fractionEnd: fractionEnd, context: context)
    }

    private func drawHistogram(histogramVal: [UInt], color: UIColor, fractionStart: CGFloat, fractionEnd: CGFloat, context: CGContext) {
        plotGraph(values: histogramVal.map({ CGFloat($0) }), color: color, fractionStart: fractionStart, fractionEnd: fractionEnd, context: context)
    }

    private func plotGraph(values: [CGFloat], color: UIColor, fractionStart: CGFloat, fractionEnd: CGFloat, context: CGContext) {
        let sampleCount = values.count

        let size = self.bounds.size
        let padding = self.layer.borderWidth + 1.0

        let levelMax = CGFloat(values.reduce(0, ({ max($0, $1) })))
        let yVals: [CGFloat] = values.map {
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
