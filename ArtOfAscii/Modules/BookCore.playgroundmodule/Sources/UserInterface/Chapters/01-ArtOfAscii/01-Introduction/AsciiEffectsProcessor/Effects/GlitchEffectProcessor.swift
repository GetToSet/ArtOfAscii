//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/23.
//

import UIKit
import CoreVideo
import Accelerate

class GlitchEffectProcessor: AsciiEffectsProcessor {

    private let characterMap = [Character]("   ...,;:clodxkO0KXNWM")

    var charactersPerRow = 80

    var characterAspectRatio = CGFloat(FontResourceProvider.JoystixMonospace.characterAspectRatio)

    var fontSize: CGFloat = 14.0

    var font: UIFont {
        return UIFont(name: FontResourceProvider.JoystixMonospace.regular.rawValue, size: fontSize)!
    }

    var lineHeight: CGFloat {
        return fontSize
    }

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer) -> vImage_Error {
        return kvImageNoError
    }

    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage? {
        var grayscaledBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&grayscaledBuffer, sourceBuffer.height, sourceBuffer.width, 8, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(grayscaledBuffer.data)
        }

        let coefficient = 1.0 / 3.0
        let divisor: Int32 = 0x1000
        let dDivisor = Double(divisor)
        var coefficientsMatrix = [
            Int16(coefficient * dDivisor),
            Int16(coefficient * dDivisor),
            Int16(coefficient * dDivisor),
            1
        ]

        // Apply a grayscale conversion
        guard vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer, &grayscaledBuffer, &coefficientsMatrix, divisor, nil, 0, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        // Apply a histogram equalization
        guard vImageEqualization_Planar8(&grayscaledBuffer, &grayscaledBuffer, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        let characterRatio = FontResourceProvider.FiraCode.characterAspectRatio
        let rowCount: Int = calculateRowCount(imageAspectRatio: CGFloat(sourceBuffer.width) / CGFloat(sourceBuffer.height))

        var scaledBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&scaledBuffer, UInt(rowCount), UInt(charactersPerRow), 8, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(scaledBuffer.data)
        }

        guard vImageScale_Planar8(&grayscaledBuffer, &scaledBuffer, nil, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }

        let dataPointer: UnsafeMutablePointer<UInt8> = scaledBuffer.data.bindMemory(to: UInt8.self, capacity: scaledBuffer.rowBytes * Int(scaledBuffer.height))

        let maxBrightness = Double(characterMap.count - 1)
        var asciiResult: String = ""

        for y in 0..<rowCount {
            for x in 0..<charactersPerRow {
                // Calculates brightness value
                let pixelBrightness = dataPointer[y * scaledBuffer.rowBytes + x]
                let mappedBrightnessVal = Double(pixelBrightness) / 255.0 * maxBrightness
                asciiResult.append(characterMap[Int(mappedBrightnessVal.rounded())])
            }
            asciiResult += "\n"
        }

        let attributedResultWhite = NSAttributedString(string: asciiResult, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])

        let attributedResultMagenta = NSAttributedString(string: asciiResult, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.effectMagenta
        ])

        let attributedResultCyan = NSAttributedString(string: asciiResult, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.effectCyan
        ])

        let glitchLevels = [-1.75, -1.5, -1.25, -1, 0, 1, 1.25, 1.5, 1.75]

        let glitchX = CGFloat(glitchLevels.randomElement()!)
        let glitchY = CGFloat(glitchLevels.randomElement()!)

        return AsciiArtRenderer.renderAsciiArt(
                font: font,
                lineHeight: lineHeight,
                background: UIColor.effectDarkGray,
                charactersPerRow: charactersPerRow,
                rows: rowCount,
                characterAspectRatio: characterAspectRatio,
                drawingProcedure: { font, lineHeight, drawingRect in
                    let magentaRect = drawingRect.offsetBy(dx: glitchX, dy: glitchY)
                    let cyanRect = drawingRect.offsetBy(dx: -glitchX, dy: -glitchY)
                    AsciiArtRenderer.drawAsAsciiArt(attributedString: attributedResultMagenta, font: font, lineHeight: lineHeight, drawingRect: magentaRect)
                    AsciiArtRenderer.drawAsAsciiArt(attributedString: attributedResultCyan, font: font, lineHeight: lineHeight, drawingRect: cyanRect)
                    AsciiArtRenderer.drawAsAsciiArt(attributedString: attributedResultWhite, font: font, lineHeight: lineHeight, drawingRect: drawingRect)
                })
    }

}

private extension UIColor {

    static var effectCyan: UIColor {
        UIColor(red:0.41, green:0.92, blue:0.91, alpha:1.0)
    }

    static var effectMagenta: UIColor {
        UIColor(red:0.96, green:0.34, blue:0.65, alpha:1.0)
    }

    static var effectDarkGray: UIColor {
        UIColor(red:0.15, green:0.03, blue:0.40, alpha:1.0)
    }

}
