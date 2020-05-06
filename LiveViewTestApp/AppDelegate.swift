//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Implements the application delegate for LiveViewTestApp with appropriate configuration points.
//

import UIKit
import PlaygroundSupport
import LiveViewHost
import BookCore

@UIApplicationMain
class AppDelegate: LiveViewHost.AppDelegate {

  override func setUpLiveView() -> PlaygroundLiveViewable {
    return BookCore.instantiateLiveView(identifier: .introduction)
  }

  override var liveViewConfiguration: LiveViewConfiguration {
      return .fullScreen
  }

}
