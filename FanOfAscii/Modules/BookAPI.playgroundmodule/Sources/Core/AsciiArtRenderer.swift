//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/20.
//

import UIKit

public class AsciiArtRenderer {

    public static func renderAsciifiedImage(_ string: String,
                                            fontName: String,
                                            size: CGFloat,
                                            foreground: UIColor,
                                            background: UIColor,
                                            charactersPerRow: Int,
                                            rows: Int,
                                            characterAspectRatio: Double) -> UIImage {
        let characterWidth = size * CGFloat(characterAspectRatio)
        let characterHeight = size
        let drawingRect = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: characterWidth * CGFloat(charactersPerRow), height: characterHeight * CGFloat(rows)))

        let renderer = UIGraphicsImageRenderer(size: drawingRect.size)
        let img = renderer.image { ctx in
            background.setFill()
            ctx.fill(drawingRect)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 0.0
            paragraphStyle.maximumLineHeight = size
            paragraphStyle.lineBreakMode = .byClipping
            let attrs = [
                NSAttributedString.Key.font: UIFont(name: fontName, size: size)!,
                NSAttributedString.Key.foregroundColor: foreground,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
            string.draw(
                    with: drawingRect,
                    options: .usesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil)
        }
        return img
    }

}
