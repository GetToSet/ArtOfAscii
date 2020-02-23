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

    private func requestImageFiltering() {
        guard let sourceImage = self.sourceImage else {
            return
        }
        let payload = EventMessage.rgbFilterRequest(
                redEnabled: redFilterButton.state == .selected,
                greenEnabled: greenFilterButton.state == .selected,
                blueEnabled: blueFilterButton.state == .selected,
                image: sourceImage
        )
        send(payload.playgroundValue, showLoadingView: true)
    }

    private func updateMagnificationCenter(centerInImageView: CGPoint) {
        if let centerInImage = self.showcaseImageView.pointInImageFor(point: centerInImageView) {
            magnifierContainerView.magnificationCenter = centerInImage
        }
    }

    private func updateMagnifierVisibility() {
        magnifierContainerView.isHidden = magnifierButton.state == .normal
    }

    override func updateShowcaseImage(image: UIImage) {
        super.updateShowcaseImage(image: image)

        magnifierContainerView.image = image
        if magnifierContainerView.magnificationCenter == nil {
            updateMagnificationCenter(centerInImageView: showcaseImageView.center)
        }
    }

    override func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        switch buttonView {
        case magnifierButton:
            updateMagnifierVisibility()
        default:
            requestImageFiltering()
        }
    }

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        magnifierContainerView.resetMagnifierPosition(animated: true)
        requestImageFiltering()
    }

    public override func liveViewMessageConnectionOpened() {
        super.liveViewMessageConnectionOpened()

        redFilterButton.state = .selected
        greenFilterButton.state = .selected
        blueFilterButton.state = .selected
        requestImageFiltering()
    }

    public override func liveViewMessageConnectionClosed() {
        super.liveViewMessageConnectionClosed()

        redFilterButton.state = .disabled
        greenFilterButton.state = .disabled
        blueFilterButton.state = .disabled
    }

}

extension HowImagesComposedViewController: MagnifierContainerViewDelegate {

    func magnifierCenterPositionChanged(point: CGPoint, containerView: MagnifierContainerView) {
        let centerInImageView = self.showcaseImageView.convert(point, from: containerView)
        updateMagnificationCenter(centerInImageView: centerInImageView)
    }

}
