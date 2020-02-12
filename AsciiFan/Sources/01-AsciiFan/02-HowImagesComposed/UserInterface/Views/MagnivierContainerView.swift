//
// Created by Bunny Wong on 2020/2/12.
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

        magnifierView.transform = .identity
        delegate?.magnificationCenterChanged?(point: self.center, containerView: self)
    }

    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let newCenter = CGPoint(x: magnifierView.center.x + translation.x, y: magnifierView.center.y + translation.y)
        if self.bounds.contains(newCenter) {
            magnifierView.center = newCenter
            delegate?.magnificationCenterChanged?(point: newCenter, containerView: self)
        }
        sender.setTranslation(CGPoint.zero, in: self)
    }

}

@objc protocol MagnifierContainerViewDelegate: AnyObject {

    @objc optional func magnificationCenterChanged(point: CGPoint, containerView: MagnifierContainerView)

}
