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

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.imageNames.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "imagePickerCollectionViewCell", for: indexPath)
            as? ImagePickerCollectionViewCell else {
            fatalError("Unexpected cell type")
        }
        cell.delegate = self
        if let selectedCellIndexPath = selectedCellIndexPath,
           indexPath == selectedCellIndexPath {
            cell.state = .selected
        } else {
            cell.state = .normal
        }
        let imageThumbnailName = dataSource.imageNames[indexPath.row].thumbnailName
        cell.setImage(named: imageThumbnailName)
        return cell
    }

    func thumbnailButtonTapped(cell: ImagePickerCollectionViewCell) {
        if let indexPath = imagePickerCollectionView.indexPath(for: cell) {
            selectedCellIndexPath = indexPath
            let imageName = dataSource.imageNames[indexPath.row].fullImageName
            imageView.image = UIImage(named: imageName)
            imagePickerCollectionView.reloadData()
        }
    }

}
