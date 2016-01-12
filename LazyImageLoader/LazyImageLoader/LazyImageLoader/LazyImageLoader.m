//
//  LazyImageLoader.m
//  LazyImageLoader
//
//  Created by Ratul Sharker on 1/12/16.
//

#import "LazyImageLoader.h"
#import "ImageDownloader.h"

#define DEBUG_LAZY_IMAGE_LOADER true

@implementation LazyImageLoader
{
    UIActivityIndicatorView *loadingActivity;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark UIView Lifecycle
- (void)didMoveToSuperview
{
    //calling the UIImageView didMoveToSuperView implementation
    [super didMoveToSuperview];
    
    if(DEBUG_LAZY_IMAGE_LOADER)
        NSLog(@"LAZY IMAGE LOADER MOVED TO %@", self.superview);
    
    if(!self.image)
    {
        if(DEBUG_LAZY_IMAGE_LOADER)
            NSLog(@"no image found, so why showing animating activity window");
        
        [self addLoadingActivityToSuperView];
    }
}

//-(void)setFrame:(CGRect)frame
//{
//    //UIView's default implementation
//    [super setFrame:frame];
//
//    if(DEBUG_LAZY_IMAGE_LOADER)
//        NSLog(@"setframe for the %@", NSStringFromCGRect(frame));
//    
//    
//    if(loadingActivity)
//    {
//        //there exists an loading activity to change the frame
//        loadingActivity.center = CGPointMake(frame.size.width / 2.0,
//                                             frame.size.height / 2.0);
//    }
//}

-(void)layoutSubviews
{
    //UIView's default implementation
    [super layoutSubviews];
    
    if(DEBUG_LAZY_IMAGE_LOADER)
        NSLog(@"frame & bound in layoutSubviews %@ %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
    
    if(loadingActivity)
    {
        //there exists an loading activity to change the frame
        loadingActivity.center = CGPointMake(self.frame.size.width / 2.0,
                                             self.frame.size.height / 2.0);
    }
}

#pragma mark UIImage Functionality
- (void)setImage:(UIImage *)image
{
    //calling the UIImageView setImage: implementation
    [super setImage:image];
    
    // do some work on basis of the image param passed
    if(image)
    {
        //we got an image to show, we got to hide the loading activity
        if(loadingActivity)
        {
            if(DEBUG_LAZY_IMAGE_LOADER)
                NSLog(@"image is not nil, thats why removing the loading activity");
            
            //checking is there any reference to the showing loading activity
            [self removeLoadingActivity];
        }
    }
    else
    {
        //we got no image, so if no loading activity is in action, then just add it
        //otherwise add a loading activity
        if(loadingActivity == nil)
        {
            if(DEBUG_LAZY_IMAGE_LOADER)
                NSLog(@"image in nil, thats why showing the loading activity");
            
            //no loading activity is shown until now
            [self addLoadingActivityToSuperView];
        }
    }
}


#pragma mark public functionality
-(void)setImageFromURL:(NSString*)url
 withCachingIdentifier:(NSString*)cachingID
            withPolicy:(REMOTE_IMAGE_GRABBING_POLICY)policy
{
    //for now, i would download the image, save in a particular image set
    switch (policy) {
        case LOAD_CACHED_IF_EXISTS:
        {
            NSString *localImagePath = [self getCompleteLocalpathWithCacheID:cachingID];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            
            if([fileMgr fileExistsAtPath:localImagePath])
            {
                //local image found get that & then set it asynchronusly
                NSOperationQueue *secondaryQueue = [[NSOperationQueue alloc] init];
                
                [secondaryQueue addOperationWithBlock:^{
                    UIImage *diskImage = [UIImage imageWithContentsOfFile:localImagePath];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        self.image = diskImage;
                    }];
                }];
            }
            else
            {
                //local image not found, so fetch it from online
                ImageDownloader *downloader = [[ImageDownloader alloc] init];
                [downloader downloadBaseURL:url
                                   savePath:[self getCompleteLocalpathWithCacheID:cachingID]
                               onCompletion:^(UIImage* image){
                                   
                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                       self.image = image;
                                   }];
                               }];
            }
        }
            break;
        case LOAD_REMOTE_IMAGE_IGNORING_CACHED:
        {
            ImageDownloader *downloader = [[ImageDownloader alloc] init];
            [downloader downloadBaseURL:url
                               savePath:[self getCompleteLocalpathWithCacheID:cachingID]
                           onCompletion:^(UIImage* image){
                               
                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                   self.image = image;
                               }];
                           }];
        }
            break;
        default:
            break;
    }
    
}

-(void)removeCachedImageWithCacheID:(NSString*)cachingID onCompletion:(void(^)(NSError*))onCompletion
{
    NSOperationQueue *secondaryQueue = [[NSOperationQueue alloc] init];
    
    [secondaryQueue addOperationWithBlock:^{
        NSString *completePath = [self getCompleteLocalpathWithCacheID:cachingID];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        if([fileMgr fileExistsAtPath:completePath])
        {
            //attempt to remove
            NSError *err;
            [fileMgr removeItemAtPath:completePath error:&err];
            
            if(DEBUG_LAZY_IMAGE_LOADER && err)
                NSLog(@"err removing cached image %@", err);
            
            onCompletion(err);
        }
        else if(onCompletion)
        {
            NSError *err = [[NSError alloc] initWithDomain:@"LazyImageLoader -- file not found to remove" code:1 userInfo:nil];
            onCompletion(err);
        }
        
    }];
}

-(NSArray<NSString*>*)getAllCachedIDS
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *err;
    
    NSArray<NSString*> *fileList = [fileMgr contentsOfDirectoryAtPath:[self getLocalBasePath] error:&err];
    
    if(DEBUG_LAZY_IMAGE_LOADER && err)
        NSLog(@"err getting all cached ids %@", err);
    
    return fileList;
}


#pragma mark private functionality
-(void)addLoadingActivityToSuperView
{
    loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingActivity.color = APP_THEME_COLOR;

    
    loadingActivity.center = CGPointMake(self.frame.size.width / 2.0,
                                         self.frame.size.height / 2.0);
    [self addSubview:loadingActivity];
    [loadingActivity startAnimating];
    
    if(DEBUG_LAZY_IMAGE_LOADER)
    {
        NSLog(@"frame of the lazy loader activity indicator view %@", NSStringFromCGRect(loadingActivity.frame));
        NSLog(@"frame of the image view is %@", NSStringFromCGPoint(self.center));
    }
    
}

-(void)removeLoadingActivity
{
    [loadingActivity stopAnimating];
    [loadingActivity removeFromSuperview];
    
    loadingActivity = nil;
}

-(NSString*)getLocalBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:LOCAL_CACHE_FOLDER_NAME];
}

-(NSString*)getCompleteLocalpathWithCacheID:(NSString*)cacheID
{
    NSString *basePath = [self getLocalBasePath];
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    if(![defaultManager fileExistsAtPath:basePath])
    {
        NSError *err;
        [defaultManager createDirectoryAtPath:basePath
                  withIntermediateDirectories:NO
                                   attributes:nil
                                        error:&err];
        
        if(err && DEBUG_LAZY_IMAGE_LOADER)
            NSLog(@"ERROR CREATING CACHE FOLDER %@", err);
    }
    
    if(DEBUG_LAZY_IMAGE_LOADER)
        NSLog(@"LOCAL IMAGE PATH :: %@", basePath);
    
    return [basePath stringByAppendingPathComponent:cacheID];
}


@end
