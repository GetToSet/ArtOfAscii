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

    @IBOutlet weak var imageScaleButton: ScaleModeButton!

    private var preprocessedImage: UIImage?

    public override func viewDidLoad() {
        super.viewDidLoad()

        preprocessButton.delegate = self

        shrinkButton.state = .disabled
        shrinkButton.delegate = self

        asciificationButton.state = .disabled
        asciificationButton.delegate = self

        saveButton.state = .disabled
        saveButton.delegate = self

        imageScaleButton.buttonState = .expand
        imageScaleButton.delegate = self
    }

    private func updatePreprocessedImage() {
        guard let rawImage = RawImage(uiImage: sourceImage) else {
            return
        }
        rawImage.applyHistogramEqualization()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = rawImage.cgImage(bitmapInfo: bitmapInfo) else {
            return
        }
        preprocessedImage = UIImage(cgImage: cgImage)
    }

    private func updateImageForButtonStates() {
        if asciificationButton.state == .selected {
            let payload = EventMessage.asciificationRequest(image: showcaseImageView.image)
            send(payload.playgroundValue)
        } else if shrinkButton.state == .selected {
            let imageToShrink = preprocessButton.state == .selected ? preprocessedImage : sourceImage
            let payload = EventMessage.shrinkingRequest(image: imageToShrink)
            send(payload.playgroundValue)
        } else if preprocessButton.state == .selected {
            if let preprocessedImage = preprocessedImage {
                updateShowcaseImage(image: preprocessedImage)
            }
        } else if let image = sourceImage {
            updateShowcaseImage(image: image)
        }
        imageScaleButton.isHidden = !(shrinkButton.state == .selected && asciificationButton.state == .normal)
    }

    private func saveCurrentImage() {
        if let imageToSave = showcaseImageView.image {
            UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(didSaveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        if asciificationButton.state == .selected {
            asciificationButton.state = .normal
            saveButton.state = .disabled
        }
        updatePreprocessedImage()
        updateImageForButtonStates()
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case saveButton:
            saveButton.state = .normal
            saveCurrentImage()
            return
        case asciificationButton:
            saveButton.state = asciificationButton.state == .selected ? .normal : .disabled
        case shrinkButton:
            imageScaleButton.buttonState = .expand
        default:
            break
        }
        if buttonView == shrinkButton || buttonView == preprocessButton {
            asciificationButton.state = preprocessButton.state == .selected && shrinkButton.state == .selected ? .normal : .disabled
            saveButton.state = .disabled
        }
        updateImageForButtonStates()
    }

    @objc func didSaveImage(image: UIImage, didFinishSavingWithError error: Error, contextInfo: UnsafeMutableRawPointer?) {
        let alert = UIAlertController(title: "Congratulations!", message: "Your ASCII art has been save to photo album.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

}

extension AsciificationLiveViewController: ScaleModeButtonDelegate {

    func didChangeButtonState(button: ScaleModeButton) {
        switch button.buttonState {
        case .shrink:
            showcaseImageView.contentMode = .center
        case .expand:
            showcaseImageView.contentMode = .scaleAspectFit
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
        shrinkButton.state = .normal
        asciificationButton.state = .disabled
        saveButton.state = .disabled
        updateImageForButtonStates()
    }

    public func liveViewMessageConnectionClosed() {
        shrinkButton.state = .disabled
        asciificationButton.state = .disabled
        if saveButton.state != .normal {
            saveButton.state = .disabled
        }
    }

}
