//
// Created by Bunny Wong on 2020/2/11.
//

import UIKit
import PlaygroundSupport

public class BaseViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    @IBOutlet weak var backgroundImageView: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background.jpg")
    }

}
