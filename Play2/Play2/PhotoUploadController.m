//
//  PhotoUploadController.m
//  Play2
//
//  Created by Jun Kit Lee on 23/5/12.
//  Copyright (c) 2012 mohawk.riceball@gmail.com. All rights reserved.
//

#import "PhotoUploadController.h"
#import "UIImage+RotateAndResize.h"

@implementation PhotoUploadController
@synthesize progressPercentage;
@synthesize imageInfo;
@synthesize hasStarted;
@synthesize hasFailed;
@synthesize delegate;

+ (NSURL *)blobstoreUploadURL
{
    NSString *serverURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Play2ServerURL"];
    return [NSURL URLWithString:[serverURL stringByAppendingPathComponent:@"upload"]];
}

- (id)initWithImageInfoDictionary:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.imageInfo = info;
    }
    
    return self;
}

- (UIImage *)originalImage
{
    return [self.imageInfo objectForKey:UIImagePickerControllerOriginalImage];
}

- (void)startUpload
{
    if (!hasStarted)
    {
        hasStarted = YES;
        hasFailed = NO;
        [self getImageUploadURLWithCompletionHandler:^(NSURL *imageUploadURL) {
            [self uploadImageToServer:imageUploadURL imageData:imageInfo];
        }];
    }

}

- (void)getImageUploadURLWithCompletionHandler: ( void (^) (NSURL *imageUploadURL) )handler
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[PhotoUploadController blobstoreUploadURL]] 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSString *imageUploadString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               handler([NSURL URLWithString:imageUploadString]);
                           }];
}

- (void)uploadImageToServer: (NSURL *)imageUploadURL imageData:(NSDictionary *)imageDictionary
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *cgName = [defaults stringForKey:@"cgName"];
    
    UIImage *theImage = [imageDictionary objectForKey:UIImagePickerControllerOriginalImage];    
    UIImage *resizedImage = [theImage imageByScalingToSize:CGSizeMake(1024, 768)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0);
    NSString *imageDate = [[[imageDictionary objectForKey:@"UIImagePickerControllerMediaMetadata"]
                            objectForKey:@"{Exif}"]
                           objectForKey:@"DateTimeOriginal"];
    NSString *imageFileName = [[[cgName stringByAppendingString:@" - "] stringByAppendingString:imageDate] stringByAppendingPathExtension:@"jpg"];
    
    
    //prepare the multipart request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:imageUploadURL];
    
    NSString *boundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    [uploadRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    uploadRequest.HTTPMethod = @"POST";
    
    //prepare the multipart POST body
    NSMutableData *postBody = [NSMutableData data];
    @autoreleasepool {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"cg_name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[cgName dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image_file\"; filename=\"%@\"\r\n", imageFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:imageData];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"image_date\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[imageDate dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    uploadRequest.HTTPBody = postBody;
    
    connection = [NSURLConnection connectionWithRequest:uploadRequest delegate:self];
}

/** NSURLConnectionDelegate methods **/

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    progressPercentage = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    [self.delegate photoUploadController:self progressUpdate:progressPercentage];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    hasStarted = NO;
    [self.delegate photoUploadDidFinish:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with %@. %@", [error localizedDescription], [error userInfo]);
    hasStarted = NO;
    hasFailed = YES;
    
    [self.delegate photoUploadController:self didFailWithError:error];
}



@end
