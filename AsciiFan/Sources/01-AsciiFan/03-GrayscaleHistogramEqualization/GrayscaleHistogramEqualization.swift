//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class GrayscaleHistogramEqualization: BaseViewController {

    @IBOutlet weak var histogramView: HistogramView!

    @IBOutlet weak var grayscaleButton: ToolBarButtonView!
    @IBOutlet weak var equalizationButton: ToolBarButtonView!

    override func didSelectImage(image: UIImage, pickerController: ImagePickerViewController) {
        super.didSelectImage(image: image, pickerController: pickerController)
        histogramView.image = image
    }

    func toolBarButtonTapped(buttonView: ToolBarButtonView) {

    }

}

extension GrayscaleHistogramEqualization: PlaygroundLiveViewMessageHandler {

    public func liveViewMessageConnectionOpened() {

    }

    public func liveViewMessageConnectionClosed() {

    }

    public func receive(_ message: PlaygroundValue) {

    }

}
