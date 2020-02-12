//
// Created by Bunny Wong on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class HowImagesComposedViewController: BaseViewController {

    @IBOutlet weak var imageView: ShowcaseImageView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        imageView.cornerRadius = 8.0
    }

}

extension HowImagesComposedViewController {

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        imageView.image = image
    }

}
