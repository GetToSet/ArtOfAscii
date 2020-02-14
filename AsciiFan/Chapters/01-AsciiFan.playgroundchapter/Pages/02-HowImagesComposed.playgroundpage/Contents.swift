//#-hidden-code

import UIKit
import PlaygroundSupport
import Accelerate

import Book_Sources

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
                    sourceBuffer: inout vImage_Buffer,
                    destBuffer: inout vImage_Buffer) {
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
    imageMatrixMultiply(sourceBuffer: &sourceBuffer, matrix: filterMatrix, destinationBuffer: &destBuffer)
}

/*:
* Note:
    In this code snippet, we transform the image by multiplying it with a custom filter matrix. If you're not familiar
    with limier algebra, the following figure will explain how this transform matrix works.
*/

//#-hidden-code
func imageMatrixMultiply(sourceBuffer: inout vImage_Buffer, matrix: [Float], destinationBuffer: inout vImage_Buffer) {
    let divisor: Int32 = 0x1000
    let fDivisor = Float(divisor)
    var matrixInt16 = matrix.map {
        Int16($0 * fDivisor)
    }
    vImageMatrixMultiply_ARGB8888(&sourceBuffer,
                                  &destinationBuffer,
                                  &matrixInt16,
                                  divisor,
                                  nil,
                                  nil,
                                  vImage_Flags(kvImageNoFlags))
}

let remoteView = getRemoteViewAsProxy()
let eventListener = EventListener(proxy: remoteView) { message in
    switch message {
    case .rgbFilterRequest(let redEnabled, let greenEnabled, let blueEnabled, let image):
        guard let image = image,
              let cgImage = image.cgImage,
              let sourceFormat = vImage_CGImageFormat(cgImage: cgImage),
              let destinationFormat = vImage_CGImageFormat(
                  bitsPerComponent: 8,
                  bitsPerPixel: 32,
                  colorSpace: CGColorSpaceCreateDeviceRGB(),
                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
              ) else {
            break
        }
        guard var sourceBuffer = try? vImage_Buffer(cgImage: cgImage, format: sourceFormat),
              var destinationBuffer = try? vImage_Buffer(
                  width: Int(sourceBuffer.width),
                  height: Int(sourceBuffer.height),
                  bitsPerPixel: sourceFormat.bitsPerPixel
              ) else {
            break
        }
        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        do {
            let toARGBConverter = try vImageConverter.make(
                sourceFormat: sourceFormat,
                destinationFormat: destinationFormat
            );
            try toARGBConverter.convert(source: sourceBuffer, destination: &destinationBuffer)
        } catch {
            break
        }
        applyRGBFilter(redEnabled: redEnabled, greenEnabled: greenEnabled, blueEnabled: blueEnabled, sourceBuffer: &sourceBuffer, destBuffer: &destinationBuffer);
        if let destImage = try? UIImage(cgImage: destinationBuffer.createCGImage(format: destinationFormat)) {
            remoteView?.send(EventMessage.imageProcessingResponse(image: destImage).playgroundValue)
        }
    default:
        break
    }
}
//#-end-hidden-code
