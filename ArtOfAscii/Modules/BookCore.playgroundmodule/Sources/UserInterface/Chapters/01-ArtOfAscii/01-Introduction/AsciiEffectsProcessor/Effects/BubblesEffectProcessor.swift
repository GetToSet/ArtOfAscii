//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/23.
//

import UIKit
import CoreVideo
import Accelerate

class BubblesEffectProcessor: AsciiEffectsProcessor {

    private let characterMap = [Character]("●●●●∙")

    var charactersPerRow = 80

    var characterAspectRatio = CGFloat(FontResourceProvider.FiraCode.characterAspectRatio)

    var fontSize: CGFloat = 14.0

    var font: UIFont {
        return UIFont(name: FontResourceProvider.FiraCode.bold.rawValue, size: fontSize)!
    }

    var lineHeight: CGFloat {
        return fontSize * characterAspectRatio
    }

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer) -> vImage_Error {
        return vImagePiecewiseGamma_Planar8(&lumaBuffer, &lumaBuffer, [1, 0, 0], 1.0 / 2.0, [1, 0], 0, vImage_Flags(kvImageNoFlags))
    }

    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage? {
        let rowCount: Int = calculateRowCount(imageAspectRatio: CGFloat(sourceBuffer.width) / CGFloat(sourceBuffer.height))

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

        let dataPointer: UnsafeMutablePointer<UInt8> = scaledBuffer.data.bindMemory(to: UInt8.self, capacity: scaledBuffer.rowBytes * Int(scaledBuffer.height))

        let maxBrightness = Double(characterMap.count - 1)
        let asciiResult = NSMutableAttributedString()

        for y in 0..<rowCount {
            for x in 0..<charactersPerRow {
                let baseAddr = y * scaledBuffer.rowBytes + x * 4
                let red = CGFloat(dataPointer[baseAddr + 1]) / 255.0
                let green = CGFloat(dataPointer[baseAddr + 2]) / 255.0
                let blue = CGFloat(dataPointer[baseAddr + 3]) / 255.0

                let pixelBrightness = (red + green + blue) / 3.0
                let mappedBrightnessVal = Double(pixelBrightness) * maxBrightness

                asciiResult.append(NSAttributedString(
                        string: String(characterMap[Int(mappedBrightnessVal.rounded())]),
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: red, green: green, blue: blue, alpha: 1)])
                )
            }
            asciiResult.append(NSAttributedString(string: "\n"))
        }

        return AsciiArtRendererInternal.renderAsciiArt(
                font: font,
                lineHeight: lineHeight,
                background: UIColor.white,
                charactersPerRow: charactersPerRow,
                rows: rowCount,
                characterAspectRatio: characterAspectRatio,
                drawingProcedure: { font, lineHeight, drawingRect in
                    AsciiArtRendererInternal.drawAsAsciiArt(attributedString: asciiResult, font: font, lineHeight: lineHeight, drawingRect: drawingRect)
                })
    }

}
