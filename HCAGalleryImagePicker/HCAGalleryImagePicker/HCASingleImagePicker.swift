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

let UIImagePickerControllerAssociatedObjectKey = UnsafeMutablePointer<Int8>.alloc(1)

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
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.hca_completion?(picker: picker, image: image)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.hca_completion?(picker: picker, image: nil)
    }
}

public extension UIImagePickerController
{
    public enum PickerMode
    {
        case ChooseImage
        case ChooseVideo
        case ChooseImageOrVideo
        case TakePhoto
        case TakeVideo
        case TakeImageOrVideo
    }
    
    public typealias UIImagePickerCompletionHandler = ((picker: UIImagePickerController, image: UIImage?) -> Void)
    
    public class func hca_showImagePickerFromViewController(viewController: UIViewController, completion: UIImagePickerCompletionHandler?)
    {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else
        {
            self.hca_showMediaPickerFromViewController(viewController, mode: .ChooseImage, completion: completion)
            return
        }
        
        let photoOptionsControler = UIAlertController()
        
        let chooseExistingAction = UIAlertAction(title: NSLocalizedString("Choose Existing", comment: "HCASingleImagePicker.chooseExisting") , style: .Default)
        {
            action in
            self.hca_showMediaPickerFromViewController(viewController, mode: .ChooseImage, completion: completion)
        }
        let takePictureAction = UIAlertAction(title: NSLocalizedString("Take a Picture", comment: "HCASingleImagePicker.takeAPicture"), style: .Default)
        {
            action in
            self.hca_showMediaPickerFromViewController(viewController, mode: .TakePhoto, completion: completion)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "HCASingleImagePicker.Cancel"), style: .Cancel, handler: nil)
        
        photoOptionsControler.addAction(chooseExistingAction)
        photoOptionsControler.addAction(takePictureAction)
        photoOptionsControler.addAction(cancelAction)
        
        viewController.presentViewController(photoOptionsControler, animated: true, completion: nil)
    }
    
    public class func hca_showMediaPickerFromViewController(viewController: UIViewController, mode: PickerMode, completion: UIImagePickerCompletionHandler?)
    {
        let imagePicker = UIImagePickerController()
        
        if (mode == .ChooseImage || mode == .ChooseVideo || mode == .ChooseImageOrVideo)
        {
            imagePicker.videoQuality = .TypeHigh
            
            if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary))
            {
                imagePicker.sourceType = .PhotoLibrary
            }
            else if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum))
            {
                imagePicker.sourceType = .SavedPhotosAlbum
            }
        }
        else
        {
            imagePicker.videoQuality = .TypeMedium
            imagePicker.sourceType = .Camera
        }
        
        if (mode == .ChooseImageOrVideo) || (mode == .TakeImageOrVideo)
        {
            imagePicker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
        }
        else if (mode == .ChooseVideo) || (mode == .TakeVideo)
        {
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
        }
        
        imagePicker.delegate = imagePicker
        imagePicker.allowsEditing = true
        imagePicker.hca_completion = completion
        viewController.presentViewController(imagePicker, animated: true, completion: nil)
    }
}