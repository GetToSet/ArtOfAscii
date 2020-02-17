//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/17.
//

import UIKit
import Accelerate
import BookCore

public extension RawImage {

    func applyLuminanceMap(_ mapping: [UInt8]) {
        let dataPointer = getMutableDataPointer()
        for i in stride(from: 0, to: format.pixelCount * 4, by: 4) {
            let red = dataPointer[i]
            let green = dataPointer[i + 1]
            let blue = dataPointer[i + 2]
            let luminance = Int((0.2126 * Float(red) + 0.7152 * Float(blue) + 0.0722 * Float(green)).rounded())
            let mappedLuminance = mapping[luminance]
            dataPointer[i] = mappedLuminance
            dataPointer[i + 1] = mappedLuminance
            dataPointer[i + 2] = mappedLuminance
        }
    }

    func multiplyByMatrix(matrix4x4: [Float]) {
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)
        var matrixInt16 = matrix4x4.map {
            Int16($0 * fDivisor)
        }
        var buffer = getBuffer()
        vImageMatrixMultiply_ARGB8888(&buffer, &buffer, &matrixInt16, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
    }

}
