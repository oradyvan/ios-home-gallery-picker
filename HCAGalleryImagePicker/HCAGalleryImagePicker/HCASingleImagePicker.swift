//
//  HCASingleImagePicker.swift
//  HomeCenter
//
//  Created by Nikita Ivaniushchenko on 8/8/16.
//  Copyright © 2016 NGTI. All rights reserved.
//

import UIKit

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
    public typealias UIImagePickerCompletionHandler = ((picker: UIImagePickerController, image: UIImage?) -> Void)
    
    public class func hca_showImagePickerFromViewController(viewController: UIViewController, completion: UIImagePickerCompletionHandler?)
    {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else
        {
            self.hca_showImagePickerFromViewController(viewController, forSourceType: .SavedPhotosAlbum, completion: completion)
            return
        }
        
        let photoOptionsControler = UIAlertController()
        
        let chooseExistingAction = UIAlertAction(title: NSLocalizedString("Choose Existing", comment: "HCASingleImagePicker.chooseExisting") , style: .Default)
        {
            action in
            self.hca_showImagePickerFromViewController(viewController, forSourceType: .SavedPhotosAlbum, completion: completion)
        }
        let takePictureAction = UIAlertAction(title: NSLocalizedString("Take a Picture", comment: "HCASingleImagePicker.takeAPicture"), style: .Default)
        {
            action in
            self.hca_showImagePickerFromViewController(viewController, forSourceType: .Camera, completion: completion)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "HCASingleImagePicker.Cancel"), style: .Cancel, handler: nil)
        
        photoOptionsControler.addAction(chooseExistingAction)
        photoOptionsControler.addAction(takePictureAction)
        photoOptionsControler.addAction(cancelAction)
        
        viewController.presentViewController(photoOptionsControler, animated: true, completion: nil)
    }
    
    public class func hca_showImagePickerFromViewController(viewController: UIViewController, forSourceType sourceType: UIImagePickerControllerSourceType, completion: UIImagePickerCompletionHandler?)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = imagePicker
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.hca_completion = completion
        viewController.presentViewController(imagePicker, animated: true, completion: nil)
    }
}