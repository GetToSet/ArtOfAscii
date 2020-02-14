//
// Created by Bunny Wong on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class GrayscaleHistogramEqualization: BaseViewController {

    @IBOutlet weak var histogramView: HistogramView!

    @IBOutlet weak var grayscaleButton: ToolBarButtonView!
    @IBOutlet weak var equalizationButton: ToolBarButtonView!

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
