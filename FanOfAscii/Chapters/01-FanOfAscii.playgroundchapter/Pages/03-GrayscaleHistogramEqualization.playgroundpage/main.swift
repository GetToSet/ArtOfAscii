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
# Grayscale, Histogram & Equalization

## Grayscale

To achieve the final result, the first thing we need to do is converting the image into a *grayscaled* version.
We can achieve this by setting it's red, green and blue scalar to the same value, which is the average. With prior
knowledge,this task should be simple now. Just construct a grayscale matrix and… it's done.

However, according to scientific researches, our eyes are more sensitive to green color than red and blue (actually,
green takes up almost 70%). To achieve better result, we can modify our coefficients a little bit, taking this into
consideration.

### 🔨Yet Another Image Filter

* Experiment:
    * In this experiment, we'll build another filter to turn a image into grayscaled version, with consideration.
    * Try to read and complete the following code snippet. When you finish, run your code and tap the *Switch to
    Grayscale* button below the image to see whether it works.
*/
//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, integer)
//#-code-completion(identifier, show, coefficientRed, coefficientGreen, coefficientBlue)
//#-editable-code

func applyGrayscaleFilter(rawImage: RawImage) {
    let coefficientRed: Float = 0.2126
    let coefficientGreen: Float = 0.7152
    let coefficientBlue: Float = 0.0722
    var filterMatrix: [Float] = [
        <#T##Red##Float#>, <#T##Red##Float#>, <#T##Red##Float#>, 0,
        <#T##Green##Float#>, <#T##Green##Float#>, <#T##Green##Float#>, 0,
        <#T##Blue##Float#>, <#T##Blue##Float#>, <#T##Blue##Float#>, 0,
        0, 0, 0, 1
    ]
    rawImage.multiplyByMatrix(matrix4x4: filterMatrix)
}

//#-end-editable-code
/*:
## Histograms

Now we've turned our image into grayscale and here comes another problem we have to solve: for some images, which are
too bright or too dark, the resulting ASCII arts may be hard to recognize, as the following figure shows.

**Histogram** is an effective tool for image processing. It visualizes the distribution of tones in an image. The X axis
represents the brightness, while the Y axis represents the relative number of pixels at that brightness value. The
following figure shows the same images as previous figure, along with histograms representing them.

### 🔬Demystification of Histograms

* Experiment:
    * Choose an image and then tap the *Show Histogram* icon below the image to show the histogram. Tap it again to
    see a histogram with separated red, green, and blue value.
    * Try to understand these graphs by associating them with tone and color distributions of images.

## Histogram Equalization

In this section we'll use a technique called **Histogram Equalization** to solve the previous problem. This technique
enhance the contrast level of images by *expanding light part to lightest and dark part to darkest*. For histogram's
perspective, it *widens* a histogram to its maximum width by redistributing colors from white to black.

### 🔨Equalize the Images

* Experiment:
    * In this experiment, we'll build a filter for **Histogram Equalization**.
    * Try to read and complete the following code snippet. When you finish it, run your code and tap the **Equalization**
    button below the image to see whether it works.
*/
//#-editable-code

func applyHistogramEqualization(rawImage: RawImage) {
    guard let histogram = rawImage.calculateLuminanceHistogram() else {
        return
    }
    var equalizationMap = [UInt8](repeating: 0, count: 256)
    let pixelCount = rawImage.format.pixelCount
    var pixelCumulative: UInt = 0
    for i in 0..<256 {
        pixelCumulative += histogram[i]
        let equalizedLuminance: Float = Float(pixelCumulative) / Float(pixelCount) * 255.0
        equalizationMap[i] = UInt8(equalizedLuminance.rounded())
    }
    rawImage.applyLuminanceMap(equalizationMap)
}

//#-end-editable-code
/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a custom filter matrix. If you're not familiar
    with limier algebra, the following figure will explain how this transform matrix works.
*/

//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .grayscaleFilterRequest(let enabled, let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        if enabled == true {
            applyGrayscaleFilter(rawImage: rawImage);
        }
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    case .equalizationRequest(let enabled, let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        if enabled == true {
            applyHistogramEqualization(rawImage: rawImage);
        }
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
