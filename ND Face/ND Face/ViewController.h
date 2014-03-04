//
//  ViewController.h
//  ND Face
//
//  Created by Matt Willmore on 2/27/14.
//  Copyright (c) 2014 University of Notre Dame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate> {
    UIImagePickerController* imgPicker;

}

- (IBAction)takePicture:(id)sender;

@end
