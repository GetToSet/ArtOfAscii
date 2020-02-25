//
// Copyright © 2020 Bunny Wong
// Created by Bunny Wong on 2020/2/20.
//

import UIKit

public extension AsciiArtRenderer {

    public typealias AsciiArtDrawingProcedure = (String, CGFloat, CGRect) -> ()

    public static func renderAsciiArt(fontName: String,
                                      size: CGFloat,
                                      background: UIColor,
                                      charactersPerRow: Int,
                                      rows: Int,
                                      characterAspectRatio: Double,
                                      drawingProcedure: AsciiArtDrawingProcedure) -> UIImage {
        let characterWidth = size * CGFloat(characterAspectRatio)
        let characterHeight = size
        let drawingRect = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: characterWidth * CGFloat(charactersPerRow), height: characterHeight * CGFloat(rows)))

        let renderer = UIGraphicsImageRenderer(size: drawingRect.size)
        let img = renderer.image { ctx in
            background.setFill()
            ctx.fill(drawingRect)
            drawingProcedure(fontName, size, drawingRect)
        }
        return img
    }

    public static func renderAsciiArt(attributedString: NSAttributedString,
                                      fontName: String,
                                      size: CGFloat,
                                      background: UIColor,
                                      charactersPerRow: Int,
                                      rows: Int,
                                      characterAspectRatio: Double) -> UIImage {
        return renderAsciiArt(fontName: fontName,
                size: size,
                background: background,
                charactersPerRow: charactersPerRow,
                rows: rows,
                characterAspectRatio: characterAspectRatio,
                drawingProcedure: { fontName, size, drawingRect in
                    drawAsAsciiArt(attributedString: attributedString, fontName: fontName, size: size, drawingRect: drawingRect)
                })
    }

    public static func drawAsAsciiArt(attributedString: NSAttributedString,
                                      fontName: String,
                                      size: CGFloat,
                                      drawingRect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 0.0
        paragraphStyle.maximumLineHeight = size
        paragraphStyle.lineBreakMode = .byClipping
        let attrs = [
            NSAttributedString.Key.font: UIFont(name: fontName, size: size)!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let finalString = NSMutableAttributedString(attributedString: attributedString)
        finalString.addAttributes(attrs, range: NSRange(location: 0, length: attributedString.string.count))
        finalString.draw(with: drawingRect, options: .usesLineFragmentOrigin, context: nil)
    }

}
