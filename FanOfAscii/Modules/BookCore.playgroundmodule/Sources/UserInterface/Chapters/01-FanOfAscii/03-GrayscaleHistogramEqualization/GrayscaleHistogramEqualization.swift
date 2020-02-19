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

    func requestGrayscaleFiltering() {
        let payload = EventMessage.grayscaleFilterRequest(image: self.sourceImage)
        send(payload.playgroundValue)
    }

    func requestEqualizationFiltering() {
        let payload = EventMessage.equalizationRequest(image: self.sourceImage)
        send(payload.playgroundValue)
    }

    func setHistogramViewHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.35 : 0) {
            let animationTransform = hidden ? CGAffineTransform(translationX: 0, y: self.histogramView.bounds.size.height) : CGAffineTransform.identity
            self.histogramView.transform = animationTransform
            self.histogramView.alpha = hidden ? 0.0 : 1.0
        }
    }

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        if grayscaleButton.state == .selected {
            if equalizationButton.state == .selected {
                requestEqualizationFiltering()
            } else {
                requestGrayscaleFiltering()
            }
        }
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case histogramButton:
            setHistogramViewHidden(!(histogramButton.state == .selected), animated: true)
            if histogramButton.state == .selected {
                histogramView.renderingMode = histogramButton.isRgbMode ? .rgb : .brightness
            }
        case grayscaleButton:
            if grayscaleButton.state == .selected {
                equalizationButton.state = .normal
                requestGrayscaleFiltering()
            } else {
                equalizationButton.state = .disabled
                requestGrayscaleFiltering()
            }
        case equalizationButton:
            if equalizationButton.state == .selected {
                requestEqualizationFiltering()
            } else {
                requestGrayscaleFiltering()
            }
        default:
            break
        }
    }

    override func updateShowcaseImage(image: UIImage) {
        super.updateShowcaseImage(image: image)
        histogramView.image = image
    }

}

extension GrayscaleHistogramEqualization: PlaygroundLiveViewMessageHandler {

    public func liveViewMessageConnectionOpened() {
        grayscaleButton.state = .normal
        equalizationButton.state = .disabled
        if let image = self.sourceImage {
            self.updateShowcaseImage(image: image)
        }
    }

    public func liveViewMessageConnectionClosed() {
        grayscaleButton.state = .disabled
        equalizationButton.state = .disabled
    }

    public func receive(_ message: PlaygroundValue) {
        guard let message = EventMessage.from(playgroundValue: message) else {
            return
        }
        switch message {
        case .imageProcessingResponse(let image):
            if let image = image {
                self.updateShowcaseImage(image: image)
            }
        default:
            break
        }
    }

}
