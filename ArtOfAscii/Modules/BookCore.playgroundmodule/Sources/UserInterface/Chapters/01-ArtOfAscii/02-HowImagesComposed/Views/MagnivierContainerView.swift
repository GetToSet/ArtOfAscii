//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/12.
//

import UIKit

class MagnifierContainerView: UIView {

    @IBOutlet weak var magnifierView: MagnifierView!
    @IBOutlet weak var magnifierWrapperView: UIView!

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
        self.clipsToBounds = false

        magnifierWrapperView.layer.shadowColor = UIColor.black.cgColor
        magnifierWrapperView.layer.shadowOpacity = 0.25
        magnifierWrapperView.layer.shadowRadius = 8.0

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        magnifierWrapperView.addGestureRecognizer(panGestureRecognizer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        resetMagnifierPosition(animated: true)
        delegate?.magnifierCenterPositionChanged(point: self.center, containerView: self)
    }

    func resetMagnifierPosition(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: {
            self.magnifierWrapperView.center = self.center
        }, completion: { _ in
            self.delegate?.magnifierCenterPositionChanged(point: self.center, containerView: self)
        })
    }

    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let newCenter = CGPoint(x: magnifierWrapperView.center.x + translation.x, y: magnifierWrapperView.center.y + translation.y)
        if self.bounds.contains(newCenter) {
            magnifierWrapperView.center = newCenter
            delegate?.magnifierCenterPositionChanged(point: newCenter, containerView: self)
        }
        sender.setTranslation(CGPoint.zero, in: self)
    }

}

@objc protocol MagnifierContainerViewDelegate: AnyObject {

    func magnifierCenterPositionChanged(point: CGPoint, containerView: MagnifierContainerView)

}
