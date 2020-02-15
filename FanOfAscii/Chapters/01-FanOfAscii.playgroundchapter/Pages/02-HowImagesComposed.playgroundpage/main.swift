//#-hidden-code
//
// Copyright © 2020 Bunny Wong
// Created on 2019/12/18.
//

import UIKit
import PlaygroundSupport
import Accelerate

import BookCore

PlaygroundPage.current.needsIndefiniteExecution = true

//#-end-hidden-code
/*:
# How Images Composed

## Pixels

Images are made up of **pixels**. Think of them as tiny square blocks with a single, solid color.

### 🔬Pixel Discovery

* Experiment:
    Choose an image and then tap the 🔎 icon in the bottom right corner to bring up the magnifier. Drag it around to
    examine how pixels compose a whole image.

## Red, Green & Blue

Each pixel has a color. To store a color, we have to use a **color model** to measure them first. The **RGB Color model**
is mostly used to represent colors in digital world.

In **RGB color model**, all colors are mixed from lights three main colors: **red, green and blue** as well as an
**alpha** attribute to describe how *opaque* the color is.

![RGB Color Model](rgb-model.png)

This model is close to the way how screens on our devices works. For old monitors with low resolution, you can
even see lighting units in these three colors with a close-up look.

![Close-up Look of LCD Screen](lcd-screen-closeup.jpg)

## Filters

**Filters** are used as the general technique for image processing. Mysterious it seems to be, a filter is more like a
mathematical function, receiving colors per pixel, recalculates them, producing a new image as output.

### 🔨Build Your First Image Filter

* Experiment:
    * In this experiment, we'll build a simple filter which takes red, green or blue component out of the source
    image.
    * Try to read and complete the following code snippet. When you finish it, run your code and tap the **R, G
    and B** button below the image to see whether it works.
*/

//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, integer)
//#-code-completion(identifier, show, coefficientRed, coefficientGreen, coefficientBlue)
func applyRGBFilter(redEnabled: Bool,
                    greenEnabled: Bool,
                    blueEnabled: Bool,
                    image: Image) {
    let coefficientRed, coefficientGreen, coefficientBlue: Float
    coefficientRed = (redEnabled ? 1 : 0)
    coefficientGreen = (greenEnabled ? 1 : 0)
    coefficientBlue = (blueEnabled ? 1 : 0)
    var filterMatrix: [Float] = [
        /*#-editable-code*/<#T##Red##Float#>/*#-end-editable-code*/, 0, 0, 0,
        0, /*#-editable-code*/<#T##Green##Float#>/*#-end-editable-code*/, 0, 0,
        0, 0, /*#-editable-code*/<#T##Blue##Float#>/*#-end-editable-code*/, 0,
        0, 0, 0, /*#-editable-code*/<#T##Alpha##Float#>/*#-end-editable-code*/
    ]
    image.multiplyByMatrix(matrix4x4: filterMatrix)
}

/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a custom filter matrix. If you're not familiar
    with limier algebra, the following figure will explain how this transform matrix works.
*/

//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .rgbFilterRequest(let redEnabled,
                           let greenEnabled,
                           let blueEnabled,
                           let uiImage):
        guard let uiImage = uiImage,
              let image = Image(uiImage: uiImage) else {
            return
        }
        applyRGBFilter(redEnabled: redEnabled,
                       greenEnabled: greenEnabled,
                       blueEnabled: blueEnabled,
                       image: image);

        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = image.cgImage(bitmapInfo: destinationBitmapInfo),
           let destImage = try? UIImage(cgImage: destCGImage) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: destImage).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
