//
//  ViewController.m
//  ND Face
//
//  Created by Matt Willmore on 2/27/14.
//  Copyright (c) 2014 University of Notre Dame. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)sendPic:(UIImage *)facePicture //added 3-25-14 to test getting response from web service
{
    NSData *facePictureData = UIImagePNGRepresentation(facePicture);
    
    NSString *url = @"http://cheepnis.cse.nd.edu:5000/eieio";
    
    NSURL *reqUrl = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqUrl];
    NSError *error;
    NSURLResponse *response;
    [request setHTTPBody:facePictureData];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        // Process any errors
        NSString *errorStr = [NSString stringWithString:[error description]];
        NSLog(@"ERROR: Unable to make connection to server; %@", errorStr);
    }
    
    NSStringEncoding responseEncoding = NSUTF8StringEncoding;
    if ([response textEncodingName]) {
        CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
        if (cfStringEncoding != kCFStringEncodingInvalidId) {
            responseEncoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
        }
    }
    NSString *dataString = [[NSString alloc] initWithData:data encoding:responseEncoding];
    
    NSLog(@"return data %@", dataString);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // set picture picker code up (should be in own controller...)
    if (imgPicker == nil) {
        imgPicker = [[UIImagePickerController alloc] init];
    }
    imgPicker.allowsEditing = NO;
    imgPicker.delegate = self;
    
    bool camera = false;
    
    if(camera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        imgPicker.mediaTypes =  mediaTypes;
        
        imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
    }
    else {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    
    [appDelegate.window.rootViewController presentViewController:imgPicker animated:YES completion:nil];
}
- (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(void)markFaces:(UIImage *)facePicture
{
    int counter;

    // draw a CI image with the previously loaded face detection picture
    CIImage* imageInput = [CIImage imageWithCGImage:facePicture.CGImage];
    
    // create a face detector - since speed is not an issue we'll use a high accuracy
    // detector
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:imageInput];
    
    // we'll iterate through every detected face.  CIFaceFeature provides us
    // with the width for the entire face, and the coordinates of each eye
    // and the mouth if detected.  Also provided are BOOL's for the eye's and
    // mouth so we can check if they already exist.
    
    counter=1;
    
    for(CIFaceFeature* faceFeature in features)
    {
        // create a UIView using the bounds of the face
        // UIView *faceView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        // faceView.backgroundColor = [UIColor clearColor];
        // faceView.frame = CGRectInset(faceFeature.bounds, faceFeature.bounds.size.width, faceFeature.bounds.size.height);
        
  //      dispatch_sync(dispatch_get_main_queue(), ^{
            
            CGRect newBounds = CGRectMake(faceFeature.bounds.origin.x, facePicture.size.height - faceFeature.bounds.origin.y, faceFeature.bounds.size.width, -faceFeature.bounds.size.height);
            UIImageWriteToSavedPhotosAlbum([self imageByCropping:facePicture toRect:newBounds],nil, nil, nil);
        
        [self sendPic:[self imageByCropping:facePicture toRect:newBounds]];
  
 //           [self insertNewObject:[self imageByCropping:facePicture toRect:newBounds]];
            
 /*           progress.alpha = 1.0;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            progress.progress = counter++/[features count];
            if (progress.progress >= 1.0) {
                progress.alpha = 0.0;
                self.navigationItem.rightBarButtonItem.enabled = YES;
                self.navigationItem.leftBarButtonItem.enabled = YES;
  
  
            }*/
            
  //      });
        
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if ([features count] == 0) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"No Faces Detected" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            alertView.tag = 55555;
            [alertView show];
        }
        
    });
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
  //  if (imgPicker.sourceType != 0) {
        UIImageWriteToSavedPhotosAlbum([info valueForKey:@"UIImagePickerControllerOriginalImage"],nil, nil, nil);
  //  }
    
 //   dispatch_async(defaultQueue, ^(void) {
//        [self markFaces:[appDelegate fixOrientation:[info valueForKey:@"UIImagePickerControllerOriginalImage"]]];
        [self markFaces:[info valueForKey:@"UIImagePickerControllerOriginalImage"]];
 //   });
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    }
    else {
 //       if ([[self picturePickerPopoverController] isPopoverVisible]) {
 //           [[self picturePickerPopoverController] dismissPopoverAnimated:YES];
      //  }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
