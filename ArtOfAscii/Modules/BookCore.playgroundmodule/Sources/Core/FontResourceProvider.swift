//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/20.
//

import Foundation
import CoreText

public struct FontFile {
    let name: String
    let extensionName: String
}

public protocol FontResource {

    static var resourceFiles: [FontFile] { get }
    static var characterAspectRatio: Double { get }

    static func register()

}

public extension FontResource {

    static func register() {
        for fontFile in resourceFiles {
            if let fontURL = Bundle.main.url(forResource: fontFile.name, withExtension: fontFile.extensionName) {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
            }
        }
    }

}

public class FontResourceProvider {

    public enum FiraCode: String, FontResource {

        case light = "FiraCode-Light"
        case retina = "FiraCode-Light_Retina"
        case bold = "FiraCode-Light_Bold"
        case medium = "FiraCode-Light_Medium"
        case regular = "FiraCode-Light_Regular"

        public static var resourceFiles = [
            FontFile(name: "FiraCode-VF", extensionName: "ttf")
        ]

        public static var characterAspectRatio = 0.6

    }

    public enum CourierPrime: String, FontResource {

        case regular = "CourierPrime"
        case bold = "CourierPrime-Bold"

        public static var resourceFiles = [
            FontFile(name: "Courier Prime", extensionName: "ttf"),
            FontFile(name: "Courier Prime Bold", extensionName: "ttf")
        ]

        public static var characterAspectRatio = 0.6

    }

    public enum Unscii16: String, FontResource {

        case regular = "unscii-16"

        public static var resourceFiles = [FontFile(name: "unscii-16", extensionName: "ttf")]

        public static var characterAspectRatio = 0.5

    }

}
