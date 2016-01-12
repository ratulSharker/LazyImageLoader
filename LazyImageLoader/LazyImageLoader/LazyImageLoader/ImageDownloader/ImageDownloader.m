//
//  ImageDownloader.m
//  Ajura
//
//  Created by Ratul Sharker on 1/7/16.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

-(void) downloadBaseURL:(NSString*)onlineImagePath
               savePath:(NSString*)localSavePath
           onCompletion:(void (^)(UIImage*))completionBlock
{
    NSOperationQueue *secondaryQueue = [[NSOperationQueue alloc] init];
    [secondaryQueue addOperationWithBlock:^{
     

        NSURL *url = [NSURL URLWithString:onlineImagePath];
        
        NSLog(@"comeplete URL %@", onlineImagePath);
        NSLog(@"completeSavePath %@", localSavePath);
        
        
        
        //now we should do the download thing
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        
        //saving the imagess :) -- we wont do that now for debug purpose
        if(image)
            [UIImagePNGRepresentation(image) writeToFile:localSavePath atomically:YES];
        

        
        if(completionBlock != nil)
        {
            completionBlock(image);
        }
    }];
}

@end
