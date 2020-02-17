//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/16.
//

import UIKit

class HistogramToolBarButtonView: ToolBarButtonView {

    var isRgbMode: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.setImage(UIImage(named: "toolbar/button-histogram-luma"), for: .normal)
    }

    override func buttonTapped(_ sender: UIButton) {
        switch self.state {
        case .normal:
            self.state = .selected
        case .selected:
            if isRgbMode {
                isRgbMode = false
                self.state = .normal
            } else {
                isRgbMode = true
            }
        case .disabled:
            break
        }
        self.delegate?.toolBarButtonTapped(buttonView: self)
    }

    override func updateAppearance() {
        super.updateAppearance()
        if isRgbMode {
            self.button.setImage(UIImage(named: "toolbar/button-histogram-rgb"), for: .normal)
        } else {
            self.button.setImage(UIImage(named: "toolbar/button-histogram-luma"), for: .normal)
        }
    }

}
