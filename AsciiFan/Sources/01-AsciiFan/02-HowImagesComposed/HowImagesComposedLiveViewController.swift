//
// Created by Bunny Wong on 2020/2/10.
//

import UIKit
import PlaygroundSupport

public class HowImagesComposedViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var imageView: ShowcaseImageView!

    @IBOutlet weak var imagePickerCollectionView: UICollectionView!

    let dataSource = ImagePickerDataSource.shard

    var selectedCellIndexPath: IndexPath?

    override public func viewDidLoad() {
        super.viewDidLoad()

        imagePickerCollectionView.delegate = self
        imagePickerCollectionView.dataSource = self
        imageView.cornerRadius = 8.0
    }

}

extension HowImagesComposedViewController: UICollectionViewDelegate, UICollectionViewDataSource, ImagePickerCollectionViewCellDelegate {

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
            cell.setImage(named: "picker-camera")
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

    func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell) {
        if let indexPath = imagePickerCollectionView.indexPath(for: cell) {
            switch indexPath.section {
            case 0:
                showImagePicker(popoverSourceView: cell)
            case 1:
                selectedCellIndexPath = indexPath
                let imageName = dataSource.imageNames[indexPath.row].fullImageName
                imageView.image = UIImage(named: imageName)
                imagePickerCollectionView.reloadData()
            default:
                break
            }
        }
    }

}

extension HowImagesComposedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true)
    }

}

