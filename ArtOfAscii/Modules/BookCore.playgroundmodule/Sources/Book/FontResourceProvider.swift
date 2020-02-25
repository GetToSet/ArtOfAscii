//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/20.
//

import Foundation
import CoreText

public protocol Font {

    static var resourceName: String { get }
    static var resourceExtension: String { get }
    static var characterAspectRatio: Double { get }

    static func register()

}

public extension Font {

    static func register() {
        guard let fontURL = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            return
        }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
    }

}

public class FontResourceProvider {

    public enum FiraCode: String, Font {

        case light = "FiraCode-Light"
        case retina = "FiraCode-Light_Retina"
        case bold = "FiraCode-Light_Bold"
        case medium = "FiraCode-Light_Medium"
        case regular = "FiraCode-Light_Regular"

        public static var resourceName: String {
            return "FiraCode-VF"
        }

        public static var resourceExtension: String {
            return "ttf"
        }

        public static var characterAspectRatio: Double {
            return 0.5860
        }

    }

}

