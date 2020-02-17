//
// Copyright © 2020 Bunny Wong
// Created on 2020/2/11.
//

import Foundation

class ImagePickerDataSource {

    struct PickerImage: Codable {

        var fullImageName:String
        var thumbnailName:String

        private enum CodingKeys : String, CodingKey {
            case fullImageName = "full"
            case thumbnailName = "thumbnail"
        }

    }

    static var shard = ImagePickerDataSource(imageListPath: Bundle.main.path(forResource: "imagePickerList", ofType: "plist"))

    let imageNames: [PickerImage]

    private init(imageListPath: String?) {
        let decoder = PropertyListDecoder()
        guard let path = imageListPath,
            let plistData = FileManager.default.contents(atPath: path),
            let imageNames = try? decoder.decode([PickerImage].self, from: plistData) else {
            self.imageNames = []
            return
        }
        self.imageNames = imageNames
    }

}
