//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport

class AsciificationLiveViewController: BaseViewController {

    @IBOutlet weak var preprocessButton: ToolBarButtonView!
    @IBOutlet weak var shrinkButton: ToolBarButtonView!
    @IBOutlet weak var asciificationButton: ToolBarButtonView!
    @IBOutlet weak var saveButton: ToolBarButtonView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        preprocessButton.state = .disabled
        preprocessButton.delegate = self

        shrinkButton.state = .disabled
        shrinkButton.delegate = self

        asciificationButton.state = .disabled
        asciificationButton.delegate = self

        saveButton.state = .disabled
        saveButton.delegate = self
    }

    private func applyPreprocessing() {
        guard let rawImage = RawImage(uiImage: sourceImage) else {
            return
        }
        rawImage.applyHistogramEqualization()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = rawImage.cgImage(bitmapInfo: bitmapInfo) else {
            return
        }
        updateShowcaseImage(image: UIImage(cgImage: cgImage))
    }

    private func requestFilteringIfNeeded() {
        if asciificationButton.state == .selected {
            let payload = EventMessage.asciificationRequest(image: showcaseImageView.image)
            send(payload.playgroundValue)
        } else if shrinkButton.state == .selected {
            let payload = EventMessage.shrinkingRequest(image: showcaseImageView.image)
            send(payload.playgroundValue)
        } else if preprocessButton.state == .selected {
            applyPreprocessing()
        } else if let image = sourceImage {
            updateShowcaseImage(image: image)
        }
    }

    private func saveCurrentImage() {

    }

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        requestFilteringIfNeeded()
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case preprocessButton:
            shrinkButton.state = preprocessButton.state == .selected ? .normal : .disabled
            asciificationButton.state = .disabled
            saveButton.state = .disabled
            requestFilteringIfNeeded()
        case shrinkButton:
            asciificationButton.state = shrinkButton.state == .selected ? .normal : .disabled
            saveButton.state = .disabled
            requestFilteringIfNeeded()
        case asciificationButton:
            saveButton.state = asciificationButton.state == .selected ? .normal : .disabled
            requestFilteringIfNeeded()
        case saveButton:
            saveButton.state = .normal
            saveCurrentImage()
        default:
            break
        }
    }

}

extension AsciificationLiveViewController: PlaygroundLiveViewMessageHandler {

    public func receive(_ message: PlaygroundValue) {
        guard let message = EventMessage.from(playgroundValue: message) else {
            return
        }
        switch message {
        case .imageProcessingResponse(let image):
            if let image = image {
                updateShowcaseImage(image: image)
            }
        default:
            break
        }
    }

    public func liveViewMessageConnectionOpened() {
        preprocessButton.state = .normal
        shrinkButton.state = .disabled
        asciificationButton.state = .disabled
        saveButton.state = .disabled
        if let image = sourceImage {
            updateShowcaseImage(image: image)
        }
    }

    public func liveViewMessageConnectionClosed() {
        preprocessButton.state = .disabled
        shrinkButton.state = .disabled
        asciificationButton.state = .disabled
        saveButton.state = .disabled
    }

}
