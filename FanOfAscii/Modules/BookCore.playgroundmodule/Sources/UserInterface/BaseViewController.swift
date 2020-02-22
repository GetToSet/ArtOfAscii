//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import UIKit
import PlaygroundSupport

public class BaseViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer,
        ImagePickerViewControllerDelegate, ToolBarButtonViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var showcaseImageCoontainerView: UIView!
    @IBOutlet weak var showcaseImageView: ShowcaseImageView!
    
    @IBOutlet weak var toolBarContainerView: UIView!

    var sourceImage: UIImage?

    var imagePickerController: ImagePickerViewController!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background-v2")

        showcaseImageView.cornerRadius = 8.0

        setupLogoImageView()
        setupToolBarBlurView()
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            assertionFailure("Segue had no identifier")
            return
        }
        switch identifier {
        case "embedImagePicker":
            let pickerController = segue.destination as! ImagePickerViewController
            self.imagePickerController = pickerController
            pickerController.delegate = self
        default:
            fatalError("Unrecognized storyboard identifier")
        }
    }

    func setupLogoImageView() {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.showcaseImageCoontainerView.insertSubview(logoImageView, belowSubview: showcaseImageView)

        logoImageView.centerXAnchor.constraint(equalTo: showcaseImageCoontainerView.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: showcaseImageCoontainerView.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 420).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: showcaseImageCoontainerView.heightAnchor).isActive = true
    }
    
    func setupToolBarBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(blurView, aboveSubview: self.backgroundImageView)

        blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: self.toolBarContainerView.topAnchor, constant: -12).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
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
