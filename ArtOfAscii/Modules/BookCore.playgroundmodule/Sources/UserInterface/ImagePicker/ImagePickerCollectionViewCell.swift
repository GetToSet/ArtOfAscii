//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/10.
//

import UIKit

class ImagePickerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var thumbnailButton: UIButton!

    weak var delegate: ImagePickerCollectionViewCellDelegate?

    override var isSelected: Bool {
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
        if self.isSelected {
            contentContainerView.layer.borderColor = UIColor.States.highlight.cgColor
        } else {
            contentContainerView.layer.borderColor = UIColor.white.cgColor
        }
    }

    @IBAction func thumbnailButtonTapped(_ sender: UIButton) {
        delegate?.thumbnailButtonTapped(cell: self)
    }

}

protocol ImagePickerCollectionViewCellDelegate: AnyObject {

    func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell)

}
