//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/15.
//

import UIKit
import PlaygroundSupport

public enum LiveViewIdentifier: String {
    case introduction
    case howImagesComposed
    case grayscaleHistogramEqualization
    case asciification
}

public func instantiateLiveView(identifier: LiveViewIdentifier) -> PlaygroundLiveViewable {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)
    let liveViewController = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
    return liveViewController
}

public func remoteViewAsLiveViewProxy() -> PlaygroundRemoteLiveViewProxy? {
    return PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy
}
