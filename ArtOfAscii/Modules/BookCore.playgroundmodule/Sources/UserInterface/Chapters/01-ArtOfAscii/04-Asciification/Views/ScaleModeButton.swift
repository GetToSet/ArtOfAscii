//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/19.
//

import UIKit

class ScaleModeButton: UIButton {

    enum ButtonState {
        case expand, shrink
    }

    var buttonState: ButtonState = .expand {
        didSet{
            updateAppearanceForSate()
            delegate?.didChangeButtonState(button: self)
        }
    }
    var delegate: ScaleModeButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.clipsToBounds = true
        self.layer.cornerRadius = 6.0
        self.alpha = 0.6

        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func updateAppearanceForSate() {
        switch buttonState {
        case .expand:
            setImage(UIImage(named: "float-button/expand"), for: .normal)
        case .shrink:
            setImage(UIImage(named: "float-button/shrink"), for: .normal)
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        switch buttonState {
        case .expand:
            buttonState = .shrink
        case .shrink:
            buttonState = .expand
        }
        updateAppearanceForSate()
    }

}

protocol ScaleModeButtonDelegate: AnyObject {

    func didChangeButtonState(button: ScaleModeButton)

}
