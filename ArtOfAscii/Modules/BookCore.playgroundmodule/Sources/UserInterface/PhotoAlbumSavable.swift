//
// Created by Bunny Wong on 2020/2/26.
//

import UIKit
import Photos

enum PhotoSavingStatus {
    case success
    case accessDenied
}

protocol PhotoAlbumSavable: AnyObject {

    var photoAlbumAccess: Bool { get set }

    func requestPhotoAlbumAccess()
    func saveImage(_ image: UIImage)

    func didSavePhotoWith(status: PhotoSavingStatus)

}

extension PhotoAlbumSavable where Self: UIViewController {

    func didSavePhotoWith(status: PhotoSavingStatus) {

    }

    func requestPhotoAlbumAccess() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            self.photoAlbumAccess = true
            break
        case .notDetermined:
            let semaphore = DispatchSemaphore(value: 0)
            PHPhotoLibrary.requestAuthorization() { status in
                if status == .authorized {
                    self.photoAlbumAccess = true
                } else {
                    self.photoAlbumAccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
        default:
            self.photoAlbumAccess = false
        }
    }

    func saveImage(_ image: UIImage) {
        self.requestPhotoAlbumAccess()
        if self.photoAlbumAccess {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            didSavePhotoWith(status: .success)
        } else {
            didSavePhotoWith(status: .accessDenied)
        }
    }

}
