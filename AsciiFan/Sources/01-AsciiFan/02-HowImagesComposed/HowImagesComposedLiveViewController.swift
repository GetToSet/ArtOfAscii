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

    override public func viewDidLoad() {
        super.viewDidLoad()

        imageView.cornerRadius = 8.0
        magnifierContainerView.delegate = self

        redFilterButton.delegate = self
        greenFilterButton.delegate = self
        blueFilterButton.delegate = self
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

    func updateShowcaseImage() {
        let payload = EventMessage.rgbFilterRequest(
            redEnabled: redFilterButton.state == .selected,
            greenEnabled: redFilterButton.state == .selected,
            blueEnabled: redFilterButton.state == .selected
        )

        send(payload.playgroundValue)
    }

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        imageView.image = image
        magnifierContainerView.image = image
        if magnifierContainerView.magnificationCenter == nil {
            repositionMagnifier(centerInImageView: imageView.center)
        }
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        if buttonView == magnifierButton {
            updateMagnifierVisibility()
        } else {
            updateShowcaseImage()
        }
    }

}

extension HowImagesComposedViewController: MagnifierContainerViewDelegate {

    func magnificationCenterChanged(point: CGPoint, containerView: MagnifierContainerView) {
        let centerInImageView = self.imageView.convert(point, from: containerView)
        repositionMagnifier(centerInImageView: centerInImageView)
    }

}
