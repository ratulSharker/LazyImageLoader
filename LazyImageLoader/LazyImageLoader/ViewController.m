//
//  ViewController.m
//  LazyImageLoader
//
//  Created by Ratul Sharker on 1/12/16.
//

#import "ViewController.h"
#import "LazyImageLoader.h"


@interface ViewController ()

@end

@implementation ViewController
{
    // view components
    IBOutlet LazyImageLoader *mViewSampleLazyLoader;
    
    IBOutlet UIStepper *mViewXValueStepper;
    IBOutlet UIStepper *mViewYValueStepper;
    IBOutlet UIStepper *mViewWidthValueStepper;
    IBOutlet UIStepper *mViewHeightValueStepper;
    
    
    //constraints
    IBOutlet NSLayoutConstraint *mConstraintLazyTop;
    IBOutlet NSLayoutConstraint *mConstraintLazyHorizontalCenter;
    IBOutlet NSLayoutConstraint *mConstraintLazyImageWidth;
    IBOutlet NSLayoutConstraint *mConstraintLazyImageHeight;
    
    
}

#pragma mark UIViewController Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions
- (IBAction)onStepperValueChanged:(id)sender
{
    UIStepper *targetStepper = (UIStepper*)sender;
    if(targetStepper == mViewXValueStepper)
    {
        //change the x position -- center constraint
        mConstraintLazyHorizontalCenter.constant = targetStepper.value;
    }
    else if (targetStepper == mViewYValueStepper)
    {
        //change the y position -- top constraint
        mConstraintLazyTop.constant = targetStepper.value;
    }
    else if (targetStepper == mViewWidthValueStepper)
    {
        mConstraintLazyImageWidth.constant = targetStepper.value;
    }
    else if (targetStepper == mViewHeightValueStepper)
    {
        mConstraintLazyImageHeight.constant = targetStepper.value;
    }
}




- (IBAction)onPressSetImagenil:(id)sender
{
    mViewSampleLazyLoader.image = nil;
}

- (IBAction)onPressBundleImage:(id)sender
{
    mViewSampleLazyLoader.image = [UIImage imageNamed:@"star_icon"];
}

- (IBAction)onPressRemoteImage:(id)sender
{
    [mViewSampleLazyLoader setImageFromURL:@"http://www.gettyimages.co.uk/gi-resources/images/frontdoor/creative/Embed/hero_dog_482206371.jpg"
                     withCachingIdentifier:@"dog.png"
                                withPolicy:LOAD_CACHED_IF_EXISTS];
}

- (IBAction)onPressRemoveParticularCache:(id)sender
{
    [mViewSampleLazyLoader removeCachedImageWithCacheID:@"dog.png"
                                           onCompletion:^(NSError *err) {
                                               
                                               if(err)
                                                   NSLog(@"error while removing %@", err);
                                               else
                                                   NSLog(@"error is nil");
                                               
                                           }];
}


- (IBAction)onPressRemoveAllCache:(id)sender
{
    NSLog(@"listing all cached id %@", [mViewSampleLazyLoader getAllCachedIDS]);
}


@end
