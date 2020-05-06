//#-hidden-code
//
// Copyright © 2020 Bunny Wong
// Created on 2019/12/18.
//

import UIKit
import PlaygroundSupport

import BookCore

PlaygroundPage.current.needsIndefiniteExecution = true

var filterMatrix = [Double]()

let assessmentHelper = AssessmentHelper()
func performCorrectnessCheck() {
    assessmentHelper.assessmentShowOnce({
        return filterMatrix == [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]
    }, pass: """
             Congratulations, You've learnt how digital images composed!

             Continue to [Preprocess Images for ASCII Art](@next)
             """
    )
}
//#-end-hidden-code
/*:
# Basics: How Images Composed

## Pixels

Images are made of **pixels**. Each pixel is a tiny square block with a single, solid color.

### 🔬Pixel Discovery

* Experiment:
    Choose an image and then tap 🔎 to bring up the magnifier. Drag it around to examine how pixels compose a
    whole image.

## Red, Green & Blue

Colors are measured in **color models**. The **RGB Color model** is close to the way how screens work and therefore the
mostly used color model in digital world.

In **RGB color model**, all colors can be produced by lights in **red, green and blue**, while most images also include
an extra **alpha** channel to describe the opacity of a color.

![RGB Color Model](rgb-model.png)

### 🔨Decomposing an Image

* Experiment:
    * The following code separates red, green and blue components from an image by multiplying it with a transform matrix.
    * Try completing the code snippet. Run your code and tap the *R, G and B* button to verify whether it works.
*/

//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, double, integer)
//#-code-completion(identifier, show, factorRed, factorGreen, factorBlue)
//#-editable-code
func applyRGBFilter(redEnabled: Bool,
                    greenEnabled: Bool,
                    blueEnabled: Bool,
                    rawImage: RawImage) {
    // Use these factors to selectively filters out specific color component.
    let factorRed, factorGreen, factorBlue: Double
    factorRed = (redEnabled ? 1 : 0)
    factorGreen = (greenEnabled ? 1 : 0)
    factorBlue = (blueEnabled ? 1 : 0)

    // For most images, color components are arranged in the order of red, green, blue and alpha, per pixel basis.
    // For alpha channel, larger values means more opaque
    filterMatrix = [
        <#T##Red##Double#>, 0, 0, 0,
        0, <#T##Green##Double#>, 0, 0,
        0, 0, <#T##Blue##Double#>, 0,
        0, 0, 0, <#T##Alpha##Double#>
    ]
    rawImage.multiplyByMatrix(matrix4x4: filterMatrix)
}

//#-end-editable-code
//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .rgbFilterRequest(let redEnabled, let greenEnabled, let blueEnabled, let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyRGBFilter(redEnabled: redEnabled, greenEnabled: greenEnabled, blueEnabled: blueEnabled, rawImage: rawImage)
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
        performCorrectnessCheck()
    default:
        break
    }
}
//#-end-hidden-code
