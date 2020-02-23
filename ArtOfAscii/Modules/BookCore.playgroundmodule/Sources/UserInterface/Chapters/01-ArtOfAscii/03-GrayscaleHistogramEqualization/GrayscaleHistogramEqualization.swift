//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class GrayscaleHistogramEqualization: BaseViewController {

    @IBOutlet weak var histogramView: HistogramView!

    @IBOutlet weak var grayscaleButton: ToolBarButtonView!
    @IBOutlet weak var histogramButton: HistogramToolBarButtonView!
    @IBOutlet weak var equalizationButton: ToolBarButtonView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        histogramButton.delegate = self

        equalizationButton.state = .disabled
        equalizationButton.delegate = self

        grayscaleButton.state = .disabled
        grayscaleButton.delegate = self

        setHistogramViewHidden(true, animated: false)
    }

    private func requestFilteringIfNeeded() {
        guard let sourceImage = self.sourceImage else {
            return
        }
        if equalizationButton.state == .selected {
            let payload = EventMessage.equalizationRequest(image: self.sourceImage)
            send(payload.playgroundValue, showLoadingView: true)
        } else if grayscaleButton.state == .selected {
            let payload = EventMessage.grayscaleFilterRequest(image: self.sourceImage)
            send(payload.playgroundValue, showLoadingView: true)
        } else {
            updateShowcaseImage(image: sourceImage)
        }
    }

    private func setHistogramViewHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.35 : 0) {
            let animationTransform = hidden ? CGAffineTransform(translationX: 0, y: self.histogramView.bounds.size.height) : CGAffineTransform.identity
            self.histogramView.transform = animationTransform
            self.histogramView.alpha = hidden ? 0.0 : 1.0
        }
    }

    override func updateShowcaseImage(image: UIImage) {
        super.updateShowcaseImage(image: image)
        histogramView.image = image
    }

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        requestFilteringIfNeeded()
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case histogramButton:
            setHistogramViewHidden(!(histogramButton.state == .selected), animated: true)
            if histogramButton.state == .selected {
                histogramView.renderingMode = histogramButton.isRgbMode ? .rgb : .brightness
            }
        case grayscaleButton:
            equalizationButton.state = grayscaleButton.state == .selected ? .normal : .disabled
            histogramView.shouldDrawCumulativePixelFrequency = grayscaleButton.state == .selected ? true : false
            requestFilteringIfNeeded()
        case equalizationButton:
            requestFilteringIfNeeded()
        default:
            break
        }
    }

    public override func liveViewMessageConnectionOpened() {
        super.liveViewMessageConnectionOpened()

        grayscaleButton.state = .normal
        equalizationButton.state = .disabled
        histogramView.shouldDrawCumulativePixelFrequency = false
        if let image = sourceImage {
            updateShowcaseImage(image: image)
        }
    }

    public override func liveViewMessageConnectionClosed() {
        super.liveViewMessageConnectionClosed()

        grayscaleButton.state = .disabled
        equalizationButton.state = .disabled
    }

}
