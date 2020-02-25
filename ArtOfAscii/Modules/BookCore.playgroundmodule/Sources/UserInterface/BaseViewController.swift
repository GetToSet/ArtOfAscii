//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import UIKit
import PlaygroundSupport

public class BaseViewController: UIViewController,
        PlaygroundLiveViewSafeAreaContainer,
        ImagePickerViewControllerDelegate,
        ToolBarButtonViewDelegate,
        PlaygroundLiveViewMessageHandler {

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var showcaseImageContainerView: UIView!
    @IBOutlet weak var showcaseImageView: ShowcaseImageView!

    @IBOutlet private weak var toolBarContainerView: UIView!

    private weak var loadingIndicatorView: UIView!

    var sourceImage: UIImage?

    var imagePickerController: ImagePickerViewController!

    var editorConnected = false

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupLogoImageView()
        setupToolBarBlurView()
        setupProcessingIndicator()

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background-v2")

        showcaseImageView.cornerRadius = 8.0

        setLoadingIndicatorHidden(true, animated: false)
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

    private func setupLogoImageView() {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.showcaseImageContainerView.insertSubview(logoImageView, belowSubview: showcaseImageView)

        logoImageView.centerXAnchor.constraint(equalTo: showcaseImageContainerView.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: showcaseImageContainerView.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 420).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: showcaseImageContainerView.heightAnchor).isActive = true
    }

    private func setupToolBarBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(blurView, aboveSubview: self.backgroundImageView)

        blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: self.toolBarContainerView.topAnchor, constant: -12).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    private func setupProcessingIndicator() {
        let indicatorBackgroundView = UIView()

        indicatorBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        indicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        self.showcaseImageContainerView.addSubview(indicatorBackgroundView)

        indicatorBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        indicatorBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        indicatorBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        indicatorBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let indicatorContainerView = UIView()

        indicatorContainerView.backgroundColor = .clear
        indicatorContainerView.translatesAutoresizingMaskIntoConstraints = false
        indicatorBackgroundView.addSubview(indicatorContainerView)

        indicatorContainerView.topAnchor.constraint(equalTo: indicatorBackgroundView.topAnchor).isActive = true
        indicatorContainerView.leadingAnchor.constraint(equalTo: indicatorBackgroundView.leadingAnchor).isActive = true
        indicatorContainerView.trailingAnchor.constraint(equalTo: indicatorBackgroundView.trailingAnchor).isActive = true
        indicatorContainerView.bottomAnchor.constraint(equalTo: showcaseImageContainerView.bottomAnchor).isActive = true

        let progressIndicator = UIActivityIndicatorView(style: .whiteLarge)
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        indicatorContainerView.addSubview(progressIndicator)
        progressIndicator.centerXAnchor.constraint(equalTo: indicatorContainerView.centerXAnchor).isActive = true
        progressIndicator.centerYAnchor.constraint(equalTo: indicatorContainerView.centerYAnchor).isActive = true

        progressIndicator.startAnimating()

        self.loadingIndicatorView = indicatorBackgroundView
    }

    func updateShowcaseImage(image: UIImage) {
        showcaseImageView.image = image
    }

    private func setLoadingIndicatorHidden(_ hidden: Bool, animated: Bool) {
        if loadingIndicatorView.isHidden == hidden {
            return
        }
        if animated {
            if loadingIndicatorView.isHidden && !hidden {
                loadingIndicatorView.alpha = 0.0
                loadingIndicatorView.isHidden = false
            }
            UIView.animate(withDuration: 0.25, delay: hidden ? 0.25 : 0, animations: {
                self.loadingIndicatorView.alpha = hidden ? 0.0 : 1.0
            }, completion: { (complete) in
                self.loadingIndicatorView.isHidden = hidden
            })
        } else {
            loadingIndicatorView.isHidden = hidden
        }
    }

    func send(_ message: PlaygroundSupport.PlaygroundValue, showLoadingView: Bool) {
        if editorConnected && showLoadingView {
            setLoadingIndicatorHidden(false, animated: true)
        }
        send(message)
    }

    func didPickImage(image: UIImage, pickerController: ImagePickerViewController) {
        sourceImage = image
        updateShowcaseImage(image: image)
    }
    
    func didPickNamedItem(name: String, pickerController: ImagePickerViewController) {
        
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {
        
    }

    public func liveViewMessageConnectionOpened() {
        editorConnected = true
    }

    public func liveViewMessageConnectionClosed() {
        editorConnected = false
        setLoadingIndicatorHidden(true, animated: true)
    }

    public func receive(_ message: PlaygroundValue) {
        guard let message = EventMessage.from(playgroundValue: message) else {
            return
        }
        switch message {
        case .imageProcessingResponse(let image):
            setLoadingIndicatorHidden(true, animated: true)
            if let image = image {
                self.updateShowcaseImage(image: image)
            }
        default:
            break
        }
    }

}
