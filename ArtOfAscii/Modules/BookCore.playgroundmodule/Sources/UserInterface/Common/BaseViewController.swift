//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import UIKit
import Photos
import PlaygroundSupport

public class BaseViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer, PlaygroundLiveViewMessageHandler {

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
            fatalError("Segue had no identifier")
        }
        switch identifier {
        case "embedImagePicker":
            let pickerController = segue.destination as! ImagePickerViewController
            imagePickerController = pickerController
            pickerController.delegate = self
        default:
            fatalError("Unrecognized storyboard identifier")
        }
    }

    func updateShowcaseImage(image: UIImage) {
        showcaseImageView.image = image
    }

    func setLoadingIndicatorHidden(_ hidden: Bool, animated: Bool) {
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
            }, completion: { _ in
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

    private func setupLogoImageView() {
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        showcaseImageContainerView.insertSubview(logoImageView, belowSubview: showcaseImageView)

        logoImageView.centerXAnchor.constraint(equalTo: showcaseImageContainerView.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: showcaseImageContainerView.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 420).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: showcaseImageContainerView.heightAnchor).isActive = true
    }

    private func setupToolBarBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, aboveSubview: backgroundImageView)

        blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: toolBarContainerView.topAnchor, constant: -12).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func setupProcessingIndicator() {
        let indicatorBackgroundView = UIView()

        indicatorBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        indicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        showcaseImageContainerView.addSubview(indicatorBackgroundView)

        indicatorBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        indicatorBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        indicatorBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        indicatorBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let indicatorContainerView = UIView()

        indicatorContainerView.backgroundColor = .clear
        indicatorContainerView.translatesAutoresizingMaskIntoConstraints = false
        indicatorBackgroundView.addSubview(indicatorContainerView)

        indicatorContainerView.topAnchor.constraint(equalTo: indicatorBackgroundView.topAnchor).isActive = true
        indicatorContainerView.leadingAnchor.constraint(equalTo: indicatorBackgroundView.leadingAnchor).isActive = true
        indicatorContainerView.trailingAnchor.constraint(equalTo: indicatorBackgroundView.trailingAnchor).isActive = true
        indicatorContainerView.bottomAnchor.constraint(equalTo: showcaseImageContainerView.bottomAnchor).isActive = true

        let progressIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        indicatorContainerView.addSubview(progressIndicator)
        progressIndicator.centerXAnchor.constraint(equalTo: indicatorContainerView.centerXAnchor).isActive = true
        progressIndicator.centerYAnchor.constraint(equalTo: indicatorContainerView.centerYAnchor).isActive = true

        progressIndicator.startAnimating()

        loadingIndicatorView = indicatorBackgroundView
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
                updateShowcaseImage(image: image)
            }
        default:
            break
        }
    }

}

extension BaseViewController: ImagePickerViewControllerDelegate {

    func didPickImage(image: UIImage, pickerController: ImagePickerViewController) {
        sourceImage = image
        updateShowcaseImage(image: image)
    }

    func didPickNamedItem(name: String, pickerController: ImagePickerViewController) {

    }

}

extension BaseViewController: ToolBarButtonViewDelegate {

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {

    }

}
