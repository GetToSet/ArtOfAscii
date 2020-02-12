//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Implements the application delegate for LiveViewTestApp with appropriate configuration points.
//

import UIKit
import PlaygroundSupport
import LiveViewHost
import Book_Sources

@UIApplicationMain
class AppDelegate: LiveViewHost.AppDelegate {

    override func setUpLiveView() -> PlaygroundLiveViewable {
        return Book_Sources.instantiateLiveView(identifier: .howImagesComposed)
    }

    override var liveViewConfiguration: LiveViewConfiguration {
        return .sideBySide
    }

}
