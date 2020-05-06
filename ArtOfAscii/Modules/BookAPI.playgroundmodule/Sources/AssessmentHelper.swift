//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/27.
//

import UIKit
import PlaygroundSupport

public class AssessmentHelper {

    public typealias AssessmentFunc = () -> Bool

    private var assessmentStatusShown = false

    public init() {

    }

    public func assessmentShowOnce(_ assessmentFunc: AssessmentFunc, pass passMessage: String?) {
        if !assessmentStatusShown && assessmentFunc() == true {
            assessmentStatusShown = true
            PlaygroundPage.current.assessmentStatus = .pass(message: passMessage)
        }
    }

}
