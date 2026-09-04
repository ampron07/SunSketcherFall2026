//
//  ImageCropping.swift
//  Sunsketcher
//
//  Created by Kelly Miller on 2/23/24.
//


import Foundation

class ImageCropping {
    let prefs = UserDefaults.standard
    
    func cropImages() {
        
        print("cropImages function called")
        
        let metadataArray = MetadataDB.shared.retrieveImageMeta()
        
        // get center img metadata from db
        let centerMetadata = findCenterImg(metadataArray: metadataArray)
        
        // convert center jpeg to UIImage
        guard let centerUIImage = UIImageFromFilePath(centerMetadata?.filepath ?? "") else { return }
        
        // get crop box from center image
        let cropBoxCoords = OpenCVWrapper.getEclipseBox(centerUIImage)
        
        // apply the crop box to all images
        for metadataRow in metadataArray {
            // skip any images that are already cropped
            if (metadataRow.isCropped != 0) {
                continue
            }
            
            // get uiimage from original image
            let uiImageOriginal = UIImageFromFilePath(metadataRow.filepath)!
            
            // crop the uiimage
            let uiImageCropped = OpenCVWrapper.croppingUIImage(uiImageOriginal, withCoords: cropBoxCoords)
            
            // save cropped image to croppedimages directory in phone
            saveCroppedImageToDocumentDirectory(uiImageCropped, metadata: metadataRow)
            
        }
        
        
        
    }
    


    func UIImageFromFilePath(_ filePath: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: filePath)
        
        // You should check if the file exists before trying to create a UIImage
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("File does not exist at path: \(filePath)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            print("Failed to get data from file at path: \(filePath)")
            return nil
        }
        
        let uiImage = UIImage(data: imageData)
        return uiImage
    }
    
    // finds center image in db and returns metadata for that image
    func findCenterImg(metadataArray: [ImageMetadata]) -> ImageMetadata? {
        
        var cnt = 0
        
        var centerMetadata: ImageMetadata? = nil
        
        let mid = metadataArray.count / 2
        
        for metadata in metadataArray {
            if (cnt == mid) {
                centerMetadata = metadata
                
                break
            }
            
            cnt += 1
        }
        
        return centerMetadata
        
    }
    
    // save cropped image to cropped image directory
    func saveCroppedImageToDocumentDirectory(_ image: UIImage, metadata: ImageMetadata) {
        // Specify the directory where images will be saved
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageSaveDirectory = documentsDirectory.appendingPathComponent("SunSketcherCroppedImgs")
        
        let prefs = UserDefaults.standard
        
        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: imageSaveDirectory, withIntermediateDirectories: true, attributes: nil)
            prefs.set(imageSaveDirectory, forKey: "imageFolderDirectory")
            
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
            return
        }
        
        // Generate filename based on unix timestamp from original image
        //let timestamp = Int64(metadata.captureTime)
        //let fileName = "IMAGE_" + "\(timestamp)"
        
        let filepath = metadata.filepath
        let filename = URL(string: filepath)?.lastPathComponent
        
        
        // Save the image to the document directory with the custom name
        //let imageURLFilename = imageSaveDirectory.appendingPathComponent(fileName)
        
        let imageURL = imageSaveDirectory.appendingPathComponent(filename!)
        
        
        let imageUrlString = "\(imageURL.relativePath)"
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            
            do {
                // try to save the image to the cropped img directory
                try imageData.write(to: imageURL)
                
                // update the filepath of the image in db
                MetadataDB.shared.updateImageFilepath(rowID: metadata.id, filepath: imageUrlString, isCropped: 1)
    
                
            } catch {
                print("Error saving image to file: \(error.localizedDescription)")
            }
        }
        
    
    }
    
}
