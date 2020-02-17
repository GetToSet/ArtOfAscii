//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit

class ImagePickerCollectionViewCell: UICollectionViewCell {

    enum ImagePickerCellState {
        case selected
        case normal
    }

    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var thumbnailButton: UIButton!

    weak var delegate: ImagePickerCollectionViewCellDelegate?

    var state: ImagePickerCellState = .normal {
        didSet {
            updateAppearance()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowContainerView.layer.cornerRadius = 4.0
        contentContainerView.layer.cornerRadius = 4.0

        contentContainerView.layer.borderWidth = 3.0

        updateAppearance()
    }

    func setImage(named imageName: String) {
        thumbnailButton.setImage(UIImage(named: imageName), for: .normal)
    }

    private func updateAppearance() {
        switch state {
        case .normal:
            contentContainerView.layer.borderColor = UIColor.white.cgColor
        case .selected:
            contentContainerView.layer.borderColor = UIColor.GlobalStates.highlight.cgColor
        }
    }

    @IBAction func thumbnailButtonTapped(_ sender: UIButton) {
        delegate?.thumbnailButtonTapped?(cell: self)
    }

}

@objc protocol ImagePickerCollectionViewCellDelegate: AnyObject {

    @objc optional func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell)

}
