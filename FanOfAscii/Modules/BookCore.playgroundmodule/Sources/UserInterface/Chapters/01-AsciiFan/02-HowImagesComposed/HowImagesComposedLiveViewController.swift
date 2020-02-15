//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class HowImagesComposedViewController: BaseViewController {

    @IBOutlet weak var magnifierContainerView: MagnifierContainerView!

    @IBOutlet weak var redFilterButton: ToolBarButtonView!
    @IBOutlet weak var greenFilterButton: ToolBarButtonView!
    @IBOutlet weak var blueFilterButton: ToolBarButtonView!
    @IBOutlet weak var magnifierButton: ToolBarButtonView!

    override public func viewDidLoad() {
        super.viewDidLoad()

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
        if let centerInImage = self.showcaseImageView.pointInImageFor(point: centerInImageView) {
            magnifierContainerView.magnificationCenter = centerInImage
        }
    }

    func updateMagnifierVisibility() {
        magnifierContainerView.isHidden = magnifierButton.state == .normal
    }

    override func updateShowcaseImage(image: UIImage) {
        super.updateShowcaseImage(image: image)

        magnifierContainerView.image = image
        if magnifierContainerView.magnificationCenter == nil {
            repositionMagnifier(centerInImageView: showcaseImageView.center)
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

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        if buttonView == magnifierButton {
            updateMagnifierVisibility()
        } else {
            requestImageFiltering()
        }
    }

}

extension HowImagesComposedViewController: MagnifierContainerViewDelegate {

    func magnificationCenterChanged(point: CGPoint, containerView: MagnifierContainerView) {
        let centerInImageView = self.showcaseImageView.convert(point, from: containerView)
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
