//
//  PhotoUploadController.h
//  Play2
//
//  Created by Jun Kit Lee on 23/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PhotoUploadController;

@protocol PhotoUploadControllerDelegate <NSObject>

- (void)photoUploadController: (PhotoUploadController *)controller progressUpdate: (float)progress;
- (void)photoUploadDidFinish:(PhotoUploadController *)controller;
- (void)photoUploadController:(PhotoUploadController *)controller didFailWithError: (NSError *)error;

@end

@interface PhotoUploadController : NSObject <NSURLConnectionDelegate> {
    NSURLConnection *connection;
}

@property (readonly) float progressPercentage;
@property (readonly) BOOL hasStarted;
@property (readonly) BOOL hasFailed;
@property (strong) NSDictionary *imageInfo;
@property (weak) id<PhotoUploadControllerDelegate> delegate;


+ (NSURL *)blobstoreUploadURL;
- (id)initWithImageInfoDictionary:(NSDictionary *)info;
- (UIImage *)originalImage;
- (void)startUpload;
- (void)getImageUploadURLWithCompletionHandler: ( void (^) (NSURL *imageUploadURL) )handler;


@end
