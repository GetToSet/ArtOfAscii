//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/12.
//

import UIKit

class ImagePickerViewController: UIViewController {

    enum ImageListType {
        case sampleImage, effectsPreview
    }

    private enum SectionType {
        case cameraRoll, sampleImage
    }

    @IBOutlet weak var imagePickerCollectionView: UICollectionView!

    var sampleImageType = ImageListType.sampleImage

    var enableCameraRollPicking = true {
        didSet {
            imagePickerCollectionView.reloadData()
        }
    }

    weak var delegate: ImagePickerViewControllerDelegate?

    private var dataSource: ImagePickerDataSource! {
        switch sampleImageType {
        case .sampleImage:
            return ImagePickerDataSource.sampleImages
        case .effectsPreview:
            return ImagePickerDataSource.effectsPreview
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        imagePickerCollectionView.delegate = self
        imagePickerCollectionView.dataSource = self
    }

    func selectFirstImage(animated: Bool) {
        imagePickerCollectionView.selectItem(
                at: IndexPath(row: 0, section: sectionFor(type: .sampleImage)!),
                animated: animated,
                scrollPosition: .centeredHorizontally)
    }

    private func sectionFor(type sectionType: SectionType) -> Int? {
        switch sectionType {
        case .cameraRoll:
            return enableCameraRollPicking ? 0 : nil
        case .sampleImage:
            return enableCameraRollPicking ? 1 : 0
        }
    }

    private func typeFor(section: Int) -> SectionType? {
        if enableCameraRollPicking && section == 0 {
            return .cameraRoll
        }
        if enableCameraRollPicking && section == 1 ||
                   !enableCameraRollPicking && section == 0 {
            return .sampleImage
        }
        return nil
    }

}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return enableCameraRollPicking ? 2 : 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = typeFor(section: section) else {
            return 0
        }
        switch section {
        case .cameraRoll:
            return 1
        case .sampleImage:
            return dataSource.items.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "imagePickerCollectionViewCell", for: indexPath)
                as? ImagePickerCollectionViewCell else {
            fatalError("Unexpected cell type")
        }
        cell.delegate = self

        guard let section = typeFor(section: indexPath.section) else {
            return cell
        }
        switch section {
        case .cameraRoll:
            cell.setImage(named: "image-picker/button-camera")
        case .sampleImage:
            if let imageThumbnailName = dataSource.items[indexPath.row].thumbnailName {
                cell.setImage(named: imageThumbnailName)
            }
        }
        return cell
    }

}

extension ImagePickerViewController: ImagePickerCollectionViewCellDelegate {

    func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell) {
        guard let indexPath = imagePickerCollectionView.indexPath(for: cell),
              let section = typeFor(section: indexPath.section) else {
            return
        }
        switch section {
        case .cameraRoll:
            showImagePicker(popoverSourceView: cell)
        case .sampleImage:
            imagePickerCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)

            let item = dataSource.items[indexPath.row]
            if let imageName = item.imageName,
               let image = UIImage(named: imageName) {
                delegate?.didPickImage(image: image, pickerController: self)
            }
            if let itemName = item.itemName {
                delegate?.didPickNamedItem(name: itemName, pickerController: self)
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
            delegate?.didPickImage(image: selectedImage, pickerController: self)
        }
        picker.dismiss(animated: true)
    }

}

@objc protocol ImagePickerViewControllerDelegate: AnyObject {

    func didPickImage(image: UIImage, pickerController: ImagePickerViewController)
    func didPickNamedItem(name: String, pickerController: ImagePickerViewController)

}
