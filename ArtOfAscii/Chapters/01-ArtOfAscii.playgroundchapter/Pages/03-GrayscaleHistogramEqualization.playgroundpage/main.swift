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
# Preprocessing: Grayscale, Histogram & Equalization

## Grayscale

Converting the image into a *grayscaled* version is the first step to the final ASCII art. This process involves
transforming each pixel's red, green and blue value to their average, which can be done by *multiplying a grayscale
matrix*.

According to researches, human eyes are way more sensitive to green than red and blue. To take this into consideration,
a dedicated set of coefficients can be applied.

### 🔨Grayscale Filtering

* Experiment:
    * You'll build a filter to turn an image into grayscaled version.
    * Try completing following code snippet. Run your code and tap the *Grayscale* button to verify whether it works.
*/
//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, double, integer)
//#-code-completion(identifier, show, coefficientRed, coefficientGreen, coefficientBlue)
//#-editable-code

func applyGrayscaleFilter(rawImage: RawImage) {
    let coefficientRed = 0.2126
    let coefficientGreen = 0.7152
    let coefficientBlue = 0.0722
    var filterMatrix: [Double] = [
        <#T##Red##Double#>, <#T##Red##Double#>, <#T##Red##Double#>, 0,
        <#T##Green##Double#>, <#T##Green##Double#>, <#T##Green##Double#>, 0,
        <#T##Blue##Double#>, <#T##Blue##Double#>, <#T##Blue##Double#>, 0,
        0, 0, 0, 1
    ]
    rawImage.multiplyByMatrix(matrix4x4: filterMatrix)
}

//#-end-editable-code
/*:
## Histograms

Images with low contrast may produce ASCII arts that are hard to recognize, as the following figure shows.

（图）

**Histogram** is an effective tool for visualizing the distribution of tones in an image. The *X axis* represents *the
brightness* while the *Y axis* represents *the number of pixels at a specific brightness value*.

（图）

### 🔬Demystification of Histograms

* Experiment:
    * Choose an image and then tap 📊 to bring up the histogram. Tapping it again to show histograms for seperated red,
    green, and blue channel.
    * Try associating histograms with the distribution of tones and colors.

## Histogram Equalization

**Histogram Equalization** is a widely used technique to enhance the contrast of images by *redistributing tones to the
whole brightness range*, spreading out pixels that has intense frequency.

（图）

### 🔨Equalizing an Image

* Experiment:
    * You'll build a filter to apply **Histogram Equalization** to images
    * Try completing following code snippet. Run your code and tap the *contrast* button to verify whether it works.
*/
//#-code-completion(everything, hide)
//#-code-completion(literal, show, float, double, integer)
//#-code-completion(identifier, show, pixelCumulative, pixelTotal, Double())
//#-editable-code

func applyHistogramEqualization(rawImage: RawImage) {
    guard let histogram = rawImage.calculateBrightnessHistogram() else {
        return
    }
    var equalizationMap = [UInt8](repeating: 0, count: 256)

    let pixelTotal = rawImage.format.pixelCount
    var pixelCumulative: UInt = 0

    // For most images, we can assume that it has 8-bit color depth, resulting 256 brightness levels
    for i in 0..<256 {
        // Histogram value represents the pixel count at current brightness level.
        // Add current pixel count to the cumulative pixel count.
        pixelCumulative += histogram[i]
        // Calculates the cumulative pixel frequency (CPF) as cumulative pixel count divided by total pixel count.
        let cumulativePixelFrequency: Double = <#T##cumulativeFrequency##Double#>

        // Map current brightness to full range according current CPF value.
        let equalizedBrightness = cumulativePixelFrequency * 255.0
        equalizationMap[i] = UInt8(equalizedBrightness.rounded())
    }
    rawImage.applyBrightnessLookup(equalizationMap)
}

//#-end-editable-code
//#-hidden-code
let remoteView = remoteViewAsLiveViewProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .grayscaleFilterRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyGrayscaleFilter(rawImage: rawImage);
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    case .equalizationRequest(let image):
        guard let rawImage = RawImage(uiImage: image) else {
            return
        }
        applyHistogramEqualization(rawImage: rawImage);
        let destinationBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        if let destCGImage = rawImage.cgImage(bitmapInfo: destinationBitmapInfo) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: UIImage(cgImage: destCGImage)).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
