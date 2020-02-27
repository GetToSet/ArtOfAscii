//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/20.
//

import UIKit

class AsciiArtRendererInternal {

    typealias AsciiArtDrawingProcedure = (UIFont, CGFloat, CGRect) -> ()

    static func renderAsciiArt(font: UIFont,
                                      lineHeight: CGFloat,
                                      background: UIColor,
                                      charactersPerRow: Int,
                                      rows: Int,
                                      characterAspectRatio: CGFloat,
                                      drawingProcedure: AsciiArtDrawingProcedure) -> UIImage {
        let characterWidth = font.pointSize * characterAspectRatio
        let characterHeight = lineHeight
        let drawingRect = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: characterWidth * CGFloat(charactersPerRow), height: characterHeight * CGFloat(rows)))

        let renderer = UIGraphicsImageRenderer(size: drawingRect.size)
        let img = renderer.image { ctx in
            background.setFill()
            ctx.fill(drawingRect)
            drawingProcedure(font, lineHeight, drawingRect)
        }
        return img
    }

    static func renderAsciiArt(attributedString: NSAttributedString,
                                      font: UIFont,
                                      lineHeight: CGFloat,
                                      background: UIColor,
                                      charactersPerRow: Int,
                                      rows: Int,
                                      characterAspectRatio: CGFloat) -> UIImage {
        return renderAsciiArt(font: font,
                lineHeight: lineHeight,
                background: background,
                charactersPerRow: charactersPerRow,
                rows: rows,
                characterAspectRatio: characterAspectRatio,
                drawingProcedure: { font , lineHeight, drawingRect in
                    drawAsAsciiArt(attributedString: attributedString,
                            font: font,
                            lineHeight: lineHeight,
                            drawingRect: drawingRect)
                })
    }

    static func drawAsAsciiArt(attributedString: NSAttributedString,
                                      font: UIFont,
                                      lineHeight: CGFloat,
                                      drawingRect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 0
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineBreakMode = .byClipping

        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
        ]

        let stringToDraw = NSMutableAttributedString(attributedString: attributedString)
        stringToDraw.addAttributes(attrs, range: NSRange(location: 0, length: attributedString.string.count))

        stringToDraw.draw(with: drawingRect, options: .usesLineFragmentOrigin, context: nil)
    }

}
