//
//  ImageDownloader.h
//  Ajura
//
//  Created by Ratul Sharker on 1/7/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject

-(void) downloadBaseURL:(NSString*)onlineImagePath
               savePath:(NSString*)localSavePath
           onCompletion:(void (^)(UIImage*))completionBlock;
@end
