//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/20.
//

import Foundation
import CoreText

public enum FiraCode: String {

    case light = "FiraCode-Light"
    case retina = "FiraCode-Light_Retina"
    case bold = "FiraCode-Light_Bold"
    case medium = "FiraCode-Light_Medium"
    case regular = "FiraCode-Light_Regular"

    public static func registerFont() {
        let fontURL = Bundle.main.url(forResource: "FiraCode-VF", withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
    }

}
