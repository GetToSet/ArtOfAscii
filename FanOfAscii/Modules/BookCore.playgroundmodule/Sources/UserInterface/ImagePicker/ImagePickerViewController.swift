//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/12.
//

import UIKit

class ImagePickerViewController: UIViewController {

    @IBOutlet weak var imagePickerCollectionView: UICollectionView!

    let dataSource = ImagePickerDataSource.shard

    var delegate: ImagePickerViewControllerDelegate?

    private var selectedCellIndexPath: IndexPath?

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        imagePickerCollectionView.delegate = self
        imagePickerCollectionView.dataSource = self
    }

    private func updateSelectionStates() {
        UIView.performWithoutAnimation {
            imagePickerCollectionView.reloadSections(IndexSet([1]))
        }
    }

}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return dataSource.imageNames.count
        default:
            return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "imagePickerCollectionViewCell", for: indexPath)
            as? ImagePickerCollectionViewCell else {
            fatalError("Unexpected cell type")
        }
        cell.delegate = self

        switch indexPath.section {
        case 0:
            cell.setImage(named: "image-picker/button-camera")
            cell.state = .selected
        case 1:
            if indexPath == selectedCellIndexPath {
                cell.state = .selected
            } else {
                cell.state = .normal
            }
            let imageThumbnailName = dataSource.imageNames[indexPath.row].thumbnailName
            cell.setImage(named: imageThumbnailName)
        default:
            break
        }
        return cell
    }

}

extension ImagePickerViewController: ImagePickerCollectionViewCellDelegate {

    func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell) {
        if let indexPath = imagePickerCollectionView.indexPath(for: cell) {
            switch indexPath.section {
            case 0:
                showImagePicker(popoverSourceView: cell)
            case 1:
                selectedCellIndexPath = indexPath
                let imageName = dataSource.imageNames[indexPath.row].fullImageName
                if let image = UIImage(named: imageName) {
                    updateSelectionStates()
                    delegate?.didSelectImage(image: image, pickerController: self)
                }
            default:
                break
            }
        }
    }

}

extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func showImagePicker(popoverSourceView: UIView) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
            self.openCamera(pickerController: imagePickerController)
        }))

        alert.addAction(UIAlertAction(title: "Choose from Album", style: .default, handler: { _ in
            self.openGallery(pickerController: imagePickerController)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.popoverPresentationController?.sourceView = popoverSourceView
        alert.popoverPresentationController?.sourceRect = popoverSourceView.bounds
        alert.popoverPresentationController?.permittedArrowDirections = .down

        self.present(alert, animated: true)
    }

    func openCamera(pickerController: UIImagePickerController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        pickerController.sourceType = .camera
        self.present(pickerController, animated: true)
    }

    func openGallery(pickerController: UIImagePickerController) {
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedCellIndexPath = nil
            updateSelectionStates()
            delegate?.didSelectImage(image: selectedImage, pickerController: self)
        }
        picker.dismiss(animated: true)
    }

}

protocol ImagePickerViewControllerDelegate: AnyObject {

    func didSelectImage(image: UIImage, pickerController: ImagePickerViewController)

}
