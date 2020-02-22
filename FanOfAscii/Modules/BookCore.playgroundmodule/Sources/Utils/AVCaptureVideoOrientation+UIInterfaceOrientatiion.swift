//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/22.
//

import UIKit
import AVFoundation

extension AVCaptureVideoOrientation {

    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            return nil
        }
    }

}
