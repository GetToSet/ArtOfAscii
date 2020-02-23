//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/12.
//

import UIKit

class MagnifierContainerView: UIView {

    @IBOutlet weak var magnifierView: MagnifierView!

    weak var delegate: MagnifierContainerViewDelegate?

    var image: UIImage {
        get {
            return magnifierView.image
        }
        set {
            magnifierView.image = newValue
        }
    }

    var magnificationCenter: CGPoint? {
        get {
            return magnifierView.magnificationCenter
        }
        set {
            magnifierView.magnificationCenter = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = .clear
        self.clipsToBounds = true

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        magnifierView.addGestureRecognizer(panGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        resetMagnifierPosition(animated: true)
        delegate?.magnifierCenterPositionChanged(point: self.center, containerView: self)
    }

    func resetMagnifierPosition(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
            self.magnifierView.center = self.center
        }, completion: { _ in
            self.delegate?.magnifierCenterPositionChanged(point: self.center, containerView: self)
        })
    }

    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let newCenter = CGPoint(x: magnifierView.center.x + translation.x, y: magnifierView.center.y + translation.y)
        if self.bounds.contains(newCenter) {
            magnifierView.center = newCenter
            delegate?.magnifierCenterPositionChanged(point: newCenter, containerView: self)
        }
        sender.setTranslation(CGPoint.zero, in: self)
    }

}

protocol MagnifierContainerViewDelegate: AnyObject {

    func magnifierCenterPositionChanged(point: CGPoint, containerView: MagnifierContainerView)

}
