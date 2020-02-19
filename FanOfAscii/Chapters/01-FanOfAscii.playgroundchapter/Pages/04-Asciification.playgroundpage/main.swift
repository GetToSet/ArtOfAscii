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
# The “ASCIIfication” Magic

## Character Map

With our image preprocessed, we can generate an ASCII art by substituting pixels in different brightness levels with
ASCII characters. To achieve the best result, we have to use a **monospaced** font, which has fixed width for all
characters.

Here is a **character map** built with font “Fira Code”, by arranging characters to fit a gradient from white to black.

（图）

## Downsampling

Since character mapping occurs per pixel basis, and characters are much wider than pixels, we have to shrink the image
before mapping. Technically, image scaling process is known as **downsampling** or broadly speaking, **resampling**.
Different *scaling algorithms* can applied to images, most of them takes nearby pixels into consideration when scaling
down an image, inorder to produce a smooth result.

### 🔨Scaling Down the Image

* Experiment:
    * In this experiment, we'll build another filter to turn a image into grayscaled version, with consideration.
    * Try to read and complete the following code snippet. When you finish, run your code and tap the *Switch to
    Grayscale* button below the image to see whether it works.
*/
//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, double, integer)
//#-code-completion(identifier, show, coefficientRed, coefficientGreen, coefficientBlue)
//#-editable-code

func getShrunkenImage(rawImage: RawImage) -> RawImage? {
    return rawImage.scaled(width: 100, height: 100)
}

//#-end-editable-code
/*:
## Final Magic

### 🔨Mapping Pixels with Characters

* Experiment:
    * In this experiment, we'll build another filter to turn a image into grayscaled version, with consideration.
    * Try to read and complete the following code snippet. When you finish, run your code and tap the *Switch to
    Grayscale* button below the image to see whether it works.
*/
//#-editable-code

func applyAsciification(rawImage: RawImage) {
    guard let histogram = rawImage.calculateBrightnessHistogram() else {
        return
    }
    var equalizationMap = [UInt8](repeating: 0, count: 256)
    let pixelCount = rawImage.format.pixelCount
    var pixelCumulative: UInt = 0
    for i in 0..<256 {
        pixelCumulative += histogram[i]
        let equalizedBrightness: Float = Float(pixelCumulative) / Float(pixelCount) * 255.0
        equalizationMap[i] = UInt8(equalizedBrightness.rounded())
    }
    rawImage.applyBrightnessMap(equalizationMap)
}

//#-end-editable-code
/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a custom filter matrix. If you're not familiar
    with limier algebra, the following figure will explain how this transform matrix works.
*/
////#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .shrinkingRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destRawImage = getShrunkenImage(rawImage: rawImage),
           let destCGImage = destRawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    case .asciificationRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyAsciification(rawImage: rawImage);
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    default:
        break
    }
}
////#-end-hidden-code
