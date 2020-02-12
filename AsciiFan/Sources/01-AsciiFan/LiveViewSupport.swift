
import UIKit
import PlaygroundSupport

public enum LiveViewIdentifier: String {
    case introduction
    case howImagesComposed
    case preprocessingImages
    case histogramAndEqualization
    case asciification
    case moreToPlay
}

public func instantiateLiveView(identifier: LiveViewIdentifier) -> PlaygroundLiveViewable {
    let storyboard = UIStoryboard(name: "LiveView", bundle: nil)
    let liveViewController = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
    return liveViewController
}
