//
// Created by Bunny Wong on 2020/2/23.
//

import UIKit
import CoreVideo
import Accelerate

class PlainEffectProcessor: AsciiEffectsProcessor {

    lazy var characterMap: [Character] = {
        Array("MWNXK0Okxdolc:;,'...   ")
    }()

    var charactersPerRow = 80

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer) {

    }

    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage? {
        var error = kvImageNoError

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
        let rowCount: Int = calculateRowCount(
                canvasRatio: Double(sourceBuffer.width) / Double(sourceBuffer.height),
                characterRatio: characterRatio)

        var scaledBuffer = vImage_Buffer()
        guard vImageBuffer_Init(&scaledBuffer, UInt(rowCount), UInt(charactersPerRow), 8, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        defer {
            free(scaledBuffer.data)
        }

        vImageScale_Planar8(&grayscaledBuffer, &scaledBuffer, nil, vImage_Flags(kvImageNoFlags))

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

        let attributedResult = NSAttributedString(string: asciiResult, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])

        return AsciiArtRenderer.renderAsciiArt(
                attributedString: attributedResult,
                fontName: FontResourceProvider.FiraCode.bold.rawValue,
                size: 14.0,
                background: UIColor.white,
                charactersPerRow: charactersPerRow,
                rows: rowCount,
                characterAspectRatio: characterRatio)
    }

}
