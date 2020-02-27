//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/23.
//

import UIKit
import Accelerate

enum AsciiEffectType: String {
    case plain
    case hacker
    case glitch
    case bubbles
    case cloudy
}

protocol AsciiEffectsProcessor {

    var charactersPerRow: Int { get }

    var characterAspectRatio: CGFloat { get }

    var fontSize: CGFloat { get }

    var font: UIFont { get }

    var lineHeight: CGFloat { get }

    func processYCbCrBuffer(lumaBuffer: inout vImage_Buffer, chromaBuffer: inout vImage_Buffer) -> vImage_Error

    func processArgbBufferToAsciiArt(buffer sourceBuffer: inout vImage_Buffer) -> UIImage?

}

extension AsciiEffectsProcessor {

    func calculateRowCount(imageAspectRatio: CGFloat) -> Int {
        let scaledHeight = CGFloat(charactersPerRow) / imageAspectRatio
        let characterRatio = characterAspectRatio * fontSize / lineHeight
        return Int((scaledHeight * characterRatio).rounded())
    }

}
