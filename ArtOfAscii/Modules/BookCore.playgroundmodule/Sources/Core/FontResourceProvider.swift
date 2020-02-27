//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/20.
//

import Foundation
import CoreText

public struct FontResourceName {
    let name: String
    let extensionName: String
}

public protocol Font {

    static var resourceNames: [FontResourceName] { get }
    static var characterAspectRatio: Double { get }

    static func register()

}

public extension Font {

    static func register() {
        for resourceName in resourceNames {
            if let fontURL = Bundle.main.url(forResource: resourceName.name, withExtension: resourceName.extensionName) {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
            }
        }
    }

}

public class FontResourceProvider {

    public enum FiraCode: String, Font {

        case light = "FiraCode-Light"
        case retina = "FiraCode-Light_Retina"
        case bold = "FiraCode-Light_Bold"
        case medium = "FiraCode-Light_Medium"
        case regular = "FiraCode-Light_Regular"

        public static var resourceNames: [FontResourceName] {
            return [FontResourceName(name: "FiraCode-VF", extensionName: "ttf")]
        }

        public static var characterAspectRatio: Double {
            return 0.6
        }

    }

    public enum CourierPrime: String, Font {

        case regular = "CourierPrime"
        case bold = "CourierPrime-Bold"

        public static var resourceNames: [FontResourceName] {
            return [
                FontResourceName(name: "Courier Prime", extensionName: "ttf"),
                FontResourceName(name: "Courier Prime Bold", extensionName: "ttf")
            ]
        }

        public static var characterAspectRatio: Double {
            return 0.6
        }

    }

    public enum Unscii16: String, Font {

        public static var resourceNames: [FontResourceName] {
            return [FontResourceName(name: "unscii-16", extensionName: "ttf")s]
        }

        case regular = "unscii-16"

        public static var characterAspectRatio: Double {
            return 0.5
        }

    }

}
