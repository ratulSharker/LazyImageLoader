//
//  LazyImageLoader.h
//  LazyImageLoader
//
//  Created by Ratul Sharker on 1/12/16.
//

#import <UIKit/UIKit.h>

#define APP_THEME_COLOR [UIColor redColor]

#define LOCAL_CACHE_FOLDER_NAME     @"lazyimages"

typedef enum {
    LOAD_REMOTE_IMAGE_IGNORING_CACHED,  //tries to load the image from the remote url -- ignores the local cached image
    LOAD_CACHED_IF_EXISTS               //tries to load the image from the local cache -- ignores the remote @ first chance
}REMOTE_IMAGE_GRABBING_POLICY;


@interface LazyImageLoader : UIImageView

-(void)setImageFromURL:(NSString*)url
 withCachingIdentifier:(NSString*)cachingID
            withPolicy:(REMOTE_IMAGE_GRABBING_POLICY)policy;

-(void)removeCachedImageWithCacheID:(NSString*)cachingID
                       onCompletion:(void(^)(NSError*))onCompletion;

-(NSArray<NSString*>*)getAllCachedIDS;

@end
