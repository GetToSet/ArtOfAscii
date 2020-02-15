//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import UIKit
import PlaygroundSupport

public class BaseViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer,
    ImagePickerViewControllerDelegate, ToolBarButtonViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var showcaseImageView: ShowcaseImageView!

    var sourceImage: UIImage?

    public override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background.jpg")

        showcaseImageView.cornerRadius = 8.0
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            assertionFailure("Segue had no identifier")
            return
        }

        switch identifier {
        case "embedImagePicker":
            let pickerController = segue.destination as! ImagePickerViewController
            pickerController.delegate = self
        default:
            fatalError("Unrecognized storyboard identifier")
        }
    }

    func updateShowcaseImage(image: UIImage) {
        showcaseImageView.image = image
    }

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        sourceImage = image
        updateShowcaseImage(image: image)
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {

    }

}
