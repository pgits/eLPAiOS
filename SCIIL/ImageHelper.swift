import Foundation
import UIKit

class ImageHelper {
    
    // MARK: - get image by file name
    class func getImage(fileName: String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var image:UIImage!
        if let dirPath = paths.first
        {
            let fullFileName = fileName + ".jpg"
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(fullFileName)
            image = UIImage(contentsOfFile: imageURL.path)
        }
        return image
    }
    
    // MARK: - check if image exists
    class func imageExists(fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let fullFileName = fileName + ".jpg"
        let filePath = url.appendingPathComponent(fullFileName)?.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath!) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - save image to directory
    class func saveImage(image: UIImage, fileName:String) {
        let fileManager = FileManager.default
        let fullFileName = fileName + ".jpg"
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fullFileName)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    // MARK: - image resizing
    class func getWidth() -> CGFloat{
        let getValue:String = Config.DEFAULTS.string(forKey: "imageSize")!
        switch(getValue) {
        case "Small":
            return 450
        case "Mid":
            return 720
        case "Big":
            return 1024
        default:
            return 1024
        }
    }
    
    // MARK: - rename file
    class func renameImage(oldFile:String, newFile:String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let oldFileName = oldFile + ".jpg"
            let newFileName = newFile + ".jpg"
            let originPath = documentDirectory.appendingPathComponent(oldFileName)
            let destinationPath = documentDirectory.appendingPathComponent(newFileName)
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
    
    class func resizeImage(image: UIImage) -> UIImage {
        let newWidth = self.getWidth()
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
