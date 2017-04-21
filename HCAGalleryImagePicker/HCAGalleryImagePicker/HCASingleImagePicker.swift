//
//  HCASingleImagePicker.swift
//  HomeCenter
//
//  Created by Nikita Ivaniushchenko on 8/8/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

import UIKit
import MobileCoreServices

private class ObjectWrapper<T>
{
    let value :T
    
    init(value:T)
    {
        self.value = value
    }
}

let UIImagePickerControllerAssociatedObjectKey = UnsafeMutablePointer<Int8>.allocate(capacity: 1)

extension UIImagePickerController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var hca_completion : UIImagePickerCompletionHandler?
    {
        get
        {
            let wrappedBlock = objc_getAssociatedObject(self, UIImagePickerControllerAssociatedObjectKey) as? ObjectWrapper<UIImagePickerCompletionHandler>
            return wrappedBlock?.value
        }
        
        set
        {
            if let newValue = newValue
            {
                let wrappedBlock = ObjectWrapper(value: newValue)
                objc_setAssociatedObject(self, UIImagePickerControllerAssociatedObjectKey, wrappedBlock, .OBJC_ASSOCIATION_RETAIN)
            }
            else
            {
                objc_setAssociatedObject(self, UIImagePickerControllerAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        // what is the media type
        guard let mediaType = info[UIImagePickerControllerMediaType] as? NSString else
        {
            self.hca_completion?(picker, .none)
            return
        }
        
        if (UTTypeEqual(mediaType, kUTTypeMovie))
        {
            // video
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else
            {
                self.hca_completion?(picker, .none)
                return
            }
            
            self.hca_completion?(picker, .video(videoURL))
            return
        }
        else if (UTTypeEqual(mediaType, kUTTypeImage))
        {
            // photo
            UIImage.io_image(forImagePickerInfo: info)
            {
                (image : UIImage!) in
             
                guard let image = image else
                {
                    self.hca_completion?(picker, .none)
                    return
                }
                
                self.hca_completion?(picker, .image(image))
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.hca_completion?(picker, .none)
    }
}

public extension UIImagePickerController
{
    public enum PickerMode
    {
        case chooseImage
        case chooseVideo
        case chooseImageOrVideo
        case takePhoto
        case takeVideo
        case takeImageOrVideo
    }
    
    public enum PickerResult
    {
        case image(UIImage)
        case video(URL)
        case none
    }
    
    public typealias UIImagePickerCompletionHandler = ((_ picker: UIImagePickerController, _ result: PickerResult) -> Void)
    
    public class func hca_showImagePickerFromViewController(_ viewController: UIViewController, completion: UIImagePickerCompletionHandler?)
    {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else
        {
            self.hca_showMediaPickerFromViewController(viewController, mode: .chooseImage, completion: completion)
            return
        }
        
        let photoOptionsControler = UIAlertController()
        
        let chooseExistingAction = UIAlertAction(title: NSLocalizedString("Choose Existing", comment: "HCASingleImagePicker.chooseExisting") , style: .default)
        {
            action in
            self.hca_showMediaPickerFromViewController(viewController, mode: .chooseImage, completion: completion)
        }
        let takePictureAction = UIAlertAction(title: NSLocalizedString("Take a Picture", comment: "HCASingleImagePicker.takeAPicture"), style: .default)
        {
            action in
            self.hca_showMediaPickerFromViewController(viewController, mode: .takePhoto, completion: completion)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "HCASingleImagePicker.Cancel"), style: .cancel, handler: nil)
        
        photoOptionsControler.addAction(chooseExistingAction)
        photoOptionsControler.addAction(takePictureAction)
        photoOptionsControler.addAction(cancelAction)
        
        viewController.present(photoOptionsControler, animated: true, completion: nil)
    }
    
    public class func hca_showMediaPickerFromViewController(_ viewController: UIViewController, mode: PickerMode, completion: UIImagePickerCompletionHandler?)
    {
        let imagePicker = UIImagePickerController()
        
        if (mode == .chooseImage || mode == .chooseVideo || mode == .chooseImageOrVideo)
        {
            imagePicker.videoQuality = .typeHigh
            
            if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary))
            {
                imagePicker.sourceType = .photoLibrary
            }
            else if (UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum))
            {
                imagePicker.sourceType = .savedPhotosAlbum
            }
        }
        else
        {
            imagePicker.videoQuality = .typeMedium
            imagePicker.sourceType = .camera
        }
        
        if (mode == .chooseImageOrVideo) || (mode == .takeImageOrVideo)
        {
            imagePicker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
        }
        else if (mode == .chooseVideo) || (mode == .takeVideo)
        {
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
        }
        
        imagePicker.delegate = imagePicker
        imagePicker.allowsEditing = true
        imagePicker.hca_completion = completion
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}
