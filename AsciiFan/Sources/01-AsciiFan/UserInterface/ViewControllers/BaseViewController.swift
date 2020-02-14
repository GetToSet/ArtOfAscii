//
// Created by Bunny Wong on 2020/2/11.
//

import UIKit
import PlaygroundSupport

public class BaseViewController: UIViewController,
    PlaygroundLiveViewSafeAreaContainer,
    ImagePickerViewControllerDelegate,
    ToolBarButtonViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background.jpg")
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

}
