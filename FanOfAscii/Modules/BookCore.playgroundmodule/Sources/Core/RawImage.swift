//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/16.
//

import UIKit
import Accelerate

public struct RgbaHistogram {

    public let red: [UInt], green: [UInt], blue: [UInt], alpha: [UInt]

}

public class ImageFormat {

    public let width: Int
    public let height: Int
    public let bytesForRow: Int
    public let bitmapInfo: CGBitmapInfo

    public lazy var pixelCount: Int = {
        return width * height
    }()

    public init(cgImage: CGImage) {
        self.width = cgImage.width
        self.height = cgImage.height
        self.bytesForRow = cgImage.bytesPerRow
        self.bitmapInfo = cgImage.bitmapInfo
    }

    public init(width: Int, height: Int, bytesForRow: Int, bitmapInfo: CGBitmapInfo) {
        self.width = width
        self.height = height
        self.bytesForRow = bytesForRow
        self.bitmapInfo = bitmapInfo
    }

}

public class RawImage {

    public let format: ImageFormat

    private let data: CFData

    public init?(uiImage: UIImage?) {
        guard let cgImage = uiImage?.cgImage,
              let bitmapData = cgImage.dataProvider?.data else {
            return nil
        }
        self.data = bitmapData
        self.format = ImageFormat(cgImage: cgImage)
    }

    public init(buffer: vImage_Buffer, bitmapInfo: CGBitmapInfo) {
        self.format = ImageFormat(
                width: Int(buffer.width),
                height: Int(buffer.height),
                bytesForRow: Int(buffer.rowBytes),
                bitmapInfo: bitmapInfo)
        self.data = Data(bytes: buffer.data, count: format.bytesForRow * format.height) as CFData
    }

    public func getMutableDataPointer() -> UnsafeMutablePointer<UInt8> {
        return UnsafeMutablePointer<UInt8>(mutating: CFDataGetBytePtr(data))
    }

    public func getBuffer() -> vImage_Buffer {
        return vImage_Buffer(
                data: getMutableDataPointer(),
                height: UInt(format.height),
                width: UInt(format.width),
                rowBytes: format.bytesForRow)
    }

    public func cgImage(bitmapInfo: CGBitmapInfo?) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let finalBitmapInfo = bitmapInfo ?? format.bitmapInfo
        guard let context = CGContext.init(
                data: getMutableDataPointer(),
                width: format.width,
                height: format.height,
                bitsPerComponent: 8,
                bytesPerRow: format.bytesForRow,
                space: colorSpace,
                bitmapInfo: finalBitmapInfo.rawValue) else {
            return nil
        }
        return context.makeImage()
    }

    public func calculateBrightnessHistogram() -> [UInt]? {
        guard let destDataPointer = malloc(format.pixelCount) else {
            return nil
        }
        defer {
            free(destDataPointer)
        }
        guard var destBuffer = getGrayscaledBuffer(dataPointer: destDataPointer) else {
            return nil
        }

        var brightness = [UInt](repeating: 0, count: 256)
        let brightnessPointer = UnsafeMutablePointer<vImagePixelCount>(&brightness)
        guard vImageHistogramCalculation_Planar8(&destBuffer, brightnessPointer, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        return brightness
    }

    public func calculateRgbHistogram() -> RgbaHistogram? {
        var sourceBuffer = getBuffer()

        var alpha = [UInt](repeating: 0, count: 256)
        var red = [UInt](repeating: 0, count: 256)
        var green = [UInt](repeating: 0, count: 256)
        var blue = [UInt](repeating: 0, count: 256)

        let alphaPtr, redPtr, greenPtr, bluePtr: UnsafeMutablePointer<vImagePixelCount>?

        alphaPtr = UnsafeMutablePointer<vImagePixelCount>(&alpha)
        redPtr = UnsafeMutablePointer<vImagePixelCount>(&red)
        greenPtr = UnsafeMutablePointer<vImagePixelCount>(&green)
        bluePtr = UnsafeMutablePointer<vImagePixelCount>(&blue)

        var rgba = [redPtr, greenPtr, bluePtr, alphaPtr]
        let histogram = UnsafeMutablePointer<UnsafeMutablePointer<vImagePixelCount>?>(&rgba)

        guard vImageHistogramCalculation_ARGB8888(&sourceBuffer, histogram, UInt32(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        return RgbaHistogram(red: red, green: green, blue: blue, alpha: alpha)
    }

    private func getGrayscaledBuffer(dataPointer: UnsafeMutableRawPointer) -> vImage_Buffer? {
        let coefficient: Float = 1.0 / 3.0

        let divisor: Int32 = 0x1000
        let fDivisor = Float(divisor)

        var coefficientsMatrix = [
            Int16(coefficient * fDivisor),
            Int16(coefficient * fDivisor),
            Int16(coefficient * fDivisor),
            1
        ]
        var destBuffer = vImage_Buffer(
                data: dataPointer,
                height: UInt(format.height),
                width: UInt(format.width),
                rowBytes: format.bytesForRow / 4)

        var sourceBuffer = getBuffer()
        if vImageMatrixMultiply_ARGB8888ToPlanar8(&sourceBuffer,
                &destBuffer, &coefficientsMatrix, divisor, nil, 0, vImage_Flags(kvImageNoFlags)) != kvImageNoError {
            return nil
        }
        return destBuffer
    }

    func applyHistogramEqualization() {
        guard let destDataPointer = malloc(format.pixelCount) else {
            return
        }
        defer {
            free(destDataPointer)
        }
        var sourceBuffer = getBuffer()
        guard var destBuffer = getGrayscaledBuffer(dataPointer: destDataPointer) else {
            return
        }
        guard vImageEqualization_Planar8(&destBuffer, &destBuffer, vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return
        }
        var alpha: [UInt8] = [UInt8](repeating: UInt8.max, count: format.pixelCount)
        var alphaBuffer = vImage_Buffer(data: &alpha, height: UInt(format.height), width: UInt(format.width), rowBytes: format.width)
        guard vImageConvert_Planar8toARGB8888(&destBuffer,
                &destBuffer,
                &destBuffer,
                &alphaBuffer,
                &sourceBuffer,
                vImage_Flags(kvImageNoFlags)) == kvImageNoError else {
            return
        }

    }

}
