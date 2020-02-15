/*
  Copyright © 2020 Bunny Wong
  Created on 2019/12/18.

  Abstract:
  * This file defines a class `Image` for holding raw image data and performs
  general processing operations, since `vImage` is not available prior to iOS13.
  This class is used throughout this book to abstract away conversion logic and
  help you focus on main concepts.
  * The class utilizes `Accelerate`, a framework that performs large-scale
  mathematical computations, utilizing hardware capabilities and optimized for
  high performance.
*/

import UIKit
import Accelerate

public class ImageFormat {

    let width: Int
    let height: Int
    let byteForRow: Int
    let bitmapInfo: CGBitmapInfo

    public init(cgImage: CGImage) {
        self.width = cgImage.width
        self.height = cgImage.height
        self.byteForRow = cgImage.bytesPerRow
        self.bitmapInfo = cgImage.bitmapInfo
    }

}

public class Image {

    private let format: ImageFormat
    private let data: CFData

    public func cgImage(bitmapInfo: CGBitmapInfo?) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let finalBitmapInfo = bitmapInfo ?? format.bitmapInfo
        guard let context = CGContext.init(data: UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(data)),
                                           width: format.width,
                                           height: format.height,
                                           bitsPerComponent: 8,
                                           bytesPerRow: format.byteForRow,
                                           space: colorSpace,
                                           bitmapInfo: finalBitmapInfo.rawValue) else {
            return nil
        }
        return context.makeImage()
    }

    public init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage,
              let bitmapData = cgImage.dataProvider?.data else {
            return nil
        }
        self.data = bitmapData
        self.format = ImageFormat(cgImage: cgImage)
    }

    private func getBuffer() -> vImage_Buffer {
        let bitmapPointer =
            UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(data))
        return vImage_Buffer(data: bitmapPointer,
                             height: UInt(format.height),
                             width: UInt(format.width),
                             rowBytes: format.byteForRow)
    }

    public func multiplyByMatrix(matrix4x4: [Float]) {
        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)
        var matrixInt16 = matrix4x4.map {
            Int16($0 * fDivisor)
        }
        var buffer = getBuffer()
        vImageMatrixMultiply_ARGB8888(&buffer,
                                      &buffer,
                                      &matrixInt16,
                                      divisor,
                                      nil,
                                      nil,
                                      vImage_Flags(kvImageNoFlags))
    }

}
