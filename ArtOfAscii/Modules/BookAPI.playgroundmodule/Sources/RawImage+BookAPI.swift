//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/17.
//

import UIKit
import Accelerate

import BookCore

public extension RawImage {

    func applyBrightnessLookup(_ mapping: [UInt8]) {
        let dataPointer = getMutableDataPointer()
        for i in stride(from: 0, to: format.pixelCount * 4, by: 4) {
            let red = dataPointer[i]
            let green = dataPointer[i + 1]
            let blue = dataPointer[i + 2]
            let brightness = Int(((Double(red) + Double(blue) + Double(green)) / 3).rounded())
            let mappedBrightness = mapping[brightness]
            dataPointer[i] = mappedBrightness
            dataPointer[i + 1] = mappedBrightness
            dataPointer[i + 2] = mappedBrightness
        }
    }

    func multiplyByMatrix(matrix4x4: [Double]) {
        let divisor: Int32 = 0x1000
        let dDivisor = Double(divisor)
        var matrixInt16 = matrix4x4.map {
            Int16($0 * dDivisor)
        }
        var buffer = getBuffer()
        vImageMatrixMultiply_ARGB8888(&buffer, &buffer, &matrixInt16, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
    }

    func scaled(width: Int, height: Int) -> RawImage? {
        let bytesPerRow = width * 4
        guard let dataPointer = malloc(height * bytesPerRow) else {
            return nil
        }
        defer {
            free(dataPointer)
        }
        var destBuffer = vImage_Buffer(
                data: dataPointer,
                height: UInt(height),
                width: UInt(width),
                rowBytes: bytesPerRow)

        var buffer = getBuffer()
        if vImageScale_ARGB8888(&buffer, &destBuffer, nil, vImage_Flags(kvImageHighQualityResampling)) != kvImageNoError {
            return nil
        }
        return RawImage(buffer: destBuffer, bitmapInfo: format.bitmapInfo)
    }

}
