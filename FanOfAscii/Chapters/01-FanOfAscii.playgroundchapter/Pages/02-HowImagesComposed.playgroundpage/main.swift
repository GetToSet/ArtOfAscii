//#-hidden-code
//
// Copyright © 2020 Bunny Wong
// Created on 2019/12/18.
//

import UIKit
import PlaygroundSupport

import BookCore

PlaygroundPage.current.needsIndefiniteExecution = true

//#-end-hidden-code
/*:
# How Images Composed

## Pixels

Images are made up of **pixels** — tiny square blocks with a single, solid color.

### 🔬Pixel Discovery

* Experiment:
    Choose an image and then tap 🔎 to bring up the magnifier. Drag it around to examine how pixels compose a
    whole image.

## Red, Green & Blue

Colors are measured in **color models**. The **RGB Color model** is the one mostly used in digital world.

In **RGB color model**, all colors can be produced by lights in **red, green and blue**, while most images also include
an extra **alpha** channel to describe the opacity of a color.

![RGB Color Model](rgb-model.png)

The RGB model is close to the way how screens work. Lighting units in these three colors can be seen with a close-up
look on many old monitors with low resolution.

![Close-up Look of LCD Screen](lcd-screen-closeup.jpg)

## Filters

**Filtering** is a general technique for image processing. A digital image filter resembles a mathematical function,
which receives pixel colors as a sequence, performing some calculations and returns a new image.

### 🔨Your First Image Filter

* Experiment:
    * You'll build a simple filter which separates red, green or blue component from the source image.
    * Try completing following code snippet. Run your code and tap the *R, G and B* button to verify whether it works.
*/

//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, integer)
//#-code-completion(identifier, show, factorRed, factorGreen, factorBlue)
//#-editable-code
func applyRGBFilter(redEnabled: Bool,
                    greenEnabled: Bool,
                    blueEnabled: Bool,
                    rawImage: RawImage) {
    let factorRed, factorGreen, factorBlue: Double
    factorRed = (redEnabled ? 1 : 0)
    factorGreen = (greenEnabled ? 1 : 0)
    factorBlue = (blueEnabled ? 1 : 0)

    var filterMatrix: [Double] = [
        <#T##Red##Double#>, 0, 0, 0,
        0, <#T##Green##Double#>, 0, 0,
        0, 0, <#T##Blue##Double#>, 0,
        0, 0, 0, <#T##Alpha##Double#>
    ]

    rawImage.multiplyByMatrix(matrix4x4: filterMatrix)
}

//#-end-editable-code
/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a transform matrix. If you're not familiar
    with linear algebra, the following figure explains how this transform matrix works.
    （图）
*/
//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .rgbFilterRequest(let redEnabled, let greenEnabled, let blueEnabled, let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyRGBFilter(redEnabled: redEnabled, greenEnabled: greenEnabled, blueEnabled: blueEnabled, rawImage: rawImage);
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
