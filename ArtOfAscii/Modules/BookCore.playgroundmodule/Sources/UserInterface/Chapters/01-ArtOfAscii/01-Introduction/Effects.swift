//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/23.
//

import UIKit
import Accelerate

enum AsciiEffects {
    case plain
    case hacker
    case glitch
    case bubbles
    case cloudy
}

protocol AsciiEffectsProcessor {

    var charactersPerRow: Int { get }

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer)
    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage?

}

extension AsciiEffectsProcessor {

    func calculateRowCount(canvasRatio: Double, characterRatio: Double) -> Int {
        let scaledHeight = Double(charactersPerRow) / canvasRatio
        return Int((scaledHeight * characterRatio).rounded())
    }

}
