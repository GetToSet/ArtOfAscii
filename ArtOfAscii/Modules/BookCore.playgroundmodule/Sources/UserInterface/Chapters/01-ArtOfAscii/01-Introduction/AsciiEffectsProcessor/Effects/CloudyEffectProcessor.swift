//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/23.
//

import UIKit
import CoreVideo
import Accelerate

class CloudyEffectProcessor: AsciiEffectsProcessor {

    private let characterMap = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    var charactersPerRow = 60

    var characterAspectRatio = CGFloat(FontResourceProvider.CourierPrime.characterAspectRatio)

    var fontSize: CGFloat = 14.0

    var font: UIFont {
        return UIFont(name: FontResourceProvider.CourierPrime.bold.rawValue, size: fontSize)!
    }

    var lineHeight: CGFloat {
        return font.capHeight + 1.0
    }

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer) -> vImage_Error {
        return kvImageNoError
    }

    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage? {
        // Computes the target size
        let characterRatio = FontResourceProvider.CourierPrime.characterAspectRatio
        let rowCount: Int = calculateRowCount(imageAspectRatio: CGFloat(sourceBuffer.width) / CGFloat(sourceBuffer.height))

        // Scale the original image
        var scaledBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&scaledBuffer, UInt(rowCount), UInt(charactersPerRow), 32, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(scaledBuffer.data)
        }

        guard vImageScale_ARGB8888(&sourceBuffer, &scaledBuffer, nil, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        // Blur the image
        var blurringTempBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&blurringTempBuffer, sourceBuffer.height, sourceBuffer.width, 32, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(blurringTempBuffer.data)
        }
        vImageCopyBuffer(&sourceBuffer, &blurringTempBuffer, 4, vImage_Flags(kvImageNoFlags))

        let kernelSize: UInt32 = 51
        vImageTentConvolve_ARGB8888(&blurringTempBuffer, &sourceBuffer, nil, 0, 0, kernelSize, kernelSize, nil, vImage_Flags(kvImageEdgeExtend))

        // Buffer for Gamma processing
        var rgbBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&rgbBuffer, sourceBuffer.height, sourceBuffer.width, 8 * 3, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(rgbBuffer.data)
        }

        // Removes the alpha channel for easier processing
        guard vImageConvert_ARGB8888toRGB888(&sourceBuffer, &rgbBuffer, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        // Put three channel onto one line for gamma adjustment
        var planarDestination = vImage_Buffer(data: rgbBuffer.data, height: rgbBuffer.height, width: rgbBuffer.width * 3, rowBytes: rgbBuffer.rowBytes)
        guard vImagePiecewiseGamma_Planar8(&planarDestination, &planarDestination, [1, 0, 0], 1.25, [1, 0], 0, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        planarDestination.width = rgbBuffer.width

        // Take out the image
        var cgImageFormat = vImage_CGImageFormat(
                bitsPerComponent: 8,
                bitsPerPixel: 8 * 3,
                colorSpace: Unmanaged.passUnretained(CGColorSpaceCreateDeviceRGB()),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                version: 0,
                decode: nil,
                renderingIntent: .defaultIntent)

        var error = kvImageNoError
        let cgImage = vImageCreateCGImageFromBuffer(&planarDestination, &cgImageFormat, nil, nil, vImage_Flags(kvImageNoFlags), &error)!

        guard error == kvImageNoError else {
            return nil
        }

        let backgroundImage = UIImage(cgImage: cgImage.takeRetainedValue())

        let dataPointer: UnsafeMutablePointer<UInt8> = scaledBuffer.data.bindMemory(to: UInt8.self, capacity: scaledBuffer.rowBytes * Int(scaledBuffer.height))

        var randomStr = ""
        for _ in 0..<rowCount {
            randomStr.append(String((0..<charactersPerRow).map { _ in
                characterMap.randomElement()!
            }))
            randomStr.append("\n")
        }

        let attributedResult = NSMutableAttributedString(string: randomStr)
        for y in 0..<rowCount {
            for x in 0..<charactersPerRow {
                let baseAddr = y * scaledBuffer.rowBytes + x * 4
                let red = CGFloat(dataPointer[baseAddr + 1]) / 255.0
                let green = CGFloat(dataPointer[baseAddr + 2]) / 255.0
                let blue = CGFloat(dataPointer[baseAddr + 3]) / 255.0

                attributedResult.addAttribute(NSAttributedString.Key.foregroundColor,
                        value: UIColor(red: red, green: green, blue: blue, alpha: 1.0),
                        range: NSRange(location: (charactersPerRow + 1) * y + x, length: 1))
            }
        }

        return AsciiArtRendererInternal.renderAsciiArt(
                font: font,
                lineHeight: lineHeight,
                background: .black,
                charactersPerRow: charactersPerRow,
                rows: rowCount,
                characterAspectRatio: characterAspectRatio,
                drawingProcedure: { font, lineHeight, drawingRect in
                    var fittingRect = drawingRect
                    let imageSize = backgroundImage.size
                    let factor = min(imageSize.width / drawingRect.size.width, imageSize.height / drawingRect.height);
                    fittingRect.size = CGSize(width: imageSize.width / factor, height: imageSize.height / factor)

                    backgroundImage.draw(in: fittingRect)

                    AsciiArtRendererInternal.drawAsAsciiArt(attributedString: attributedResult, font: font, lineHeight: lineHeight, drawingRect: drawingRect)
                })
    }

}
