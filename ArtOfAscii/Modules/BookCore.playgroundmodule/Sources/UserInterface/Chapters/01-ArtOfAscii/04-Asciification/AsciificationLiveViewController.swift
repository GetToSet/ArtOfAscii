//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport

class AsciificationLiveViewController: BaseViewController, PhotoAlbumSavable {

    @IBOutlet weak var preprocessButton: ToolBarButtonView!
    @IBOutlet weak var shrinkButton: ToolBarButtonView!
    @IBOutlet weak var asciificationButton: ToolBarButtonView!
    @IBOutlet weak var saveButton: ToolBarButtonView!

    @IBOutlet weak var imageScaleButton: ScaleModeButton!

    var photoAlbumAccess = false

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

        imageScaleButton.isHidden = true
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
            if let image = showcaseImageView.image {
                let payload = EventMessage.asciificationRequest(image: image)
                send(payload.playgroundValue, showLoadingView: true)
            }
        } else if shrinkButton.state == .selected {
            if let imageToShrink = preprocessButton.state == .selected ? preprocessedImage : sourceImage {
                let payload = EventMessage.shrinkingRequest(image: imageToShrink)
                send(payload.playgroundValue, showLoadingView: true)
            }
        } else if preprocessButton.state == .selected {
            if let preprocessedImage = preprocessedImage {
                setLoadingIndicatorHidden(false, animated: true)
                updateShowcaseImage(image: preprocessedImage)
                setLoadingIndicatorHidden(true, animated: true)
            }
        } else {
            if let image = sourceImage {
                updateShowcaseImage(image: image)
            }
        }
        imageScaleButton.isHidden = !(shrinkButton.state == .selected && asciificationButton.state != .selected)
    }

    override func didPickImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didPickImage(image: image, pickerController: pickerController)
        if asciificationButton.state == .selected {
            asciificationButton.state = .normal
            saveButton.state = .disabled
        }
        updatePreprocessedImage()
        updateImageForButtonStates()
    }

    private func saveCurrentImage() {
        guard let imageToSave = showcaseImageView.image else {
            return
        }
        saveImage(imageToSave)
    }

    func didSavePhotoWith(status: PhotoSavingStatus) {
        let alert: UIAlertController
        switch status {
        case .success:
            alert = UIAlertController(title: "Congratulations!",
                    message: "Your ASCII art has been save to photo album.",
                    preferredStyle: .alert)
        case .accessDenied:
            alert = UIAlertController(title: "Sorry",
                    message: "Unable to save your ASCII art because the permission is not granted.",
                    preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }


    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case saveButton:
            saveButton.state = .normal
            saveCurrentImage()
            return
        case asciificationButton:
            imageScaleButton.buttonState = .expand
            saveButton.state = asciificationButton.state == .selected ? .normal : .disabled
        case shrinkButton:
            imageScaleButton.buttonState = .shrink
        default:
            break
        }
        if buttonView == shrinkButton || buttonView == preprocessButton {
            asciificationButton.state = preprocessButton.state == .selected && shrinkButton.state == .selected ? .normal : .disabled
            saveButton.state = .disabled
        }
        updateImageForButtonStates()
    }

    public override func liveViewMessageConnectionOpened() {
        super.liveViewMessageConnectionOpened()

        preprocessButton.state = .normal
        shrinkButton.state = .normal
        asciificationButton.state = .disabled
        saveButton.state = .disabled
        updateImageForButtonStates()
    }

    public override func liveViewMessageConnectionClosed() {
        super.liveViewMessageConnectionClosed()

        shrinkButton.state = .disabled
        asciificationButton.state = .disabled
        if saveButton.state != .normal {
            saveButton.state = .disabled
        }
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
