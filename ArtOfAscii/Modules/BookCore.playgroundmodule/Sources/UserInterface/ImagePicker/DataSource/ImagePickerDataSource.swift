//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import Foundation

class ImagePickerDataSource {

    struct PickerImage: Codable {

        var itemName: String?
        var imageName: String?
        var thumbnailName:String

        private enum CodingKeys : String, CodingKey {
            case itemName = "item"
            case imageName = "full"
            case thumbnailName = "thumbnail"
        }

    }

    static var sampleImages = ImagePickerDataSource(imageListPath: Bundle.main.path(forResource: "sampleImageList", ofType: "plist"))
    static var effectsPreview = ImagePickerDataSource(imageListPath: Bundle.main.path(forResource: "effectsPreviewList", ofType: "plist"))

    let items: [PickerImage]

    private init(imageListPath: String?) {
        let decoder = PropertyListDecoder()
        guard let path = imageListPath,
            let plistData = FileManager.default.contents(atPath: path),
            let imageNames = try? decoder.decode([PickerImage].self, from: plistData) else {
            self.items = []
            return
        }
        self.items = imageNames
    }

}
