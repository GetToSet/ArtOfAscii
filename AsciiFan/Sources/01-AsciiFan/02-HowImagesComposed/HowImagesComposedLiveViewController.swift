//
// Created by Bunny Wong on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class HowImagesComposedViewController: BaseViewController {

    @IBOutlet weak var imageView: ShowcaseImageView!

    @IBOutlet weak var magnifierContainerView: MagnifierContainerView!

    @IBOutlet weak var magnifierToolBarButton: ToolBarButtonView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        imageView.cornerRadius = 8.0
        magnifierContainerView.delegate = self

        magnifierToolBarButton.delegate = self

        magnifierContainerView.isHidden = magnifierToolBarButton.state == .normal
    }

    func repositionMagnifier(centerInImageView: CGPoint) {
        if let centerInImage = self.imageView.pointInImageFor(point: centerInImageView) {
            magnifierContainerView.magnificationCenter = centerInImage
        }
    }

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        imageView.image = image
        magnifierContainerView.image = image
        if magnifierContainerView.magnificationCenter == nil {
            repositionMagnifier(centerInImageView: imageView.center)
        }
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        if buttonView == magnifierToolBarButton {
            magnifierContainerView.isHidden = buttonView.state == .normal
        }
    }

}

extension HowImagesComposedViewController: MagnifierContainerViewDelegate {

    func magnificationCenterChanged(point: CGPoint, containerView: MagnifierContainerView) {
        let centerInImageView = self.imageView.convert(point, from: containerView)
        repositionMagnifier(centerInImageView: centerInImageView)
    }

}
