//
// Created by Bunny Wong on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class HowImagesComposedViewController: BaseViewController {

    @IBOutlet weak var imageView: ShowcaseImageView!

    @IBOutlet weak var magnifierContainerView: MagnifierContainerView!

    @IBOutlet weak var redFilterButton: ToolBarButtonView!
    @IBOutlet weak var greenFilterButton: ToolBarButtonView!
    @IBOutlet weak var blueFilterButton: ToolBarButtonView!
    @IBOutlet weak var magnifierButton: ToolBarButtonView!

    private var sourceImage: UIImage?

    override public func viewDidLoad() {
        super.viewDidLoad()

        imageView.cornerRadius = 8.0
        magnifierContainerView.delegate = self

        redFilterButton.state = .disabled
        redFilterButton.delegate = self

        greenFilterButton.state = .disabled
        greenFilterButton.delegate = self

        blueFilterButton.state = .disabled
        blueFilterButton.delegate = self

        magnifierButton.state = .normal
        magnifierButton.delegate = self

        updateMagnifierVisibility()
    }

    func repositionMagnifier(centerInImageView: CGPoint) {
        if let centerInImage = self.imageView.pointInImageFor(point: centerInImageView) {
            magnifierContainerView.magnificationCenter = centerInImage
        }
    }

    func updateMagnifierVisibility() {
        magnifierContainerView.isHidden = magnifierButton.state == .normal
    }

    func updateShowcaseImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        imageView.image = image
        magnifierContainerView.image = image
        if magnifierContainerView.magnificationCenter == nil {
            repositionMagnifier(centerInImageView: imageView.center)
        }
    }

    func requestImageFiltering() {
        let payload = EventMessage.rgbFilterRequest(
            redEnabled: redFilterButton.state == .selected,
            greenEnabled: greenFilterButton.state == .selected,
            blueEnabled: blueFilterButton.state == .selected,
            image: sourceImage
        )
        send(payload.playgroundValue)
    }

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        sourceImage = image
        updateShowcaseImage(image: image)
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        if buttonView == magnifierButton {
            updateMagnifierVisibility()
        } else {
            requestImageFiltering()
        }
    }

}

extension HowImagesComposedViewController: MagnifierContainerViewDelegate {

    func magnificationCenterChanged(point: CGPoint, containerView: MagnifierContainerView) {
        let centerInImageView = self.imageView.convert(point, from: containerView)
        repositionMagnifier(centerInImageView: centerInImageView)
    }

}

extension HowImagesComposedViewController: PlaygroundLiveViewMessageHandler {

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
        redFilterButton.state = .selected
        greenFilterButton.state = .selected
        blueFilterButton.state = .selected
    }

    public func liveViewMessageConnectionClosed() {
        redFilterButton.state = .disabled
        greenFilterButton.state = .disabled
        blueFilterButton.state = .disabled
        requestImageFiltering()
    }

}
