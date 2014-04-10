//
//  SplashPageViewController.m
//  CPW T-Shirt Locator
//
//  Created by Samir Wadhwania on 4/6/14.
//  Copyright (c) 2014 Samir Wadhwania. All rights reserved.
//

#import "SplashPageViewController.h"

@interface SplashPageViewController ()

@end

@implementation SplashPageViewController
@synthesize accountStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    UIView* loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    loginView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    //Title
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    title.text = @"MIT CPW 2014";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"NeutraText-Bold" size:40];
    [loginView addSubview:title];
    
    //Subtitle
    UILabel* subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 30)];
    subtitle.text = @"Free T-Shirt Locator";
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.textColor = [UIColor whiteColor];
    subtitle.font = [UIFont fontWithName:@"NeutraText-Demi" size:28];
    subtitle.numberOfLines = 1;
    [loginView addSubview:subtitle];
    
    //Bottom
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(22.5, self.view.frame.size.height-68, 275, 44);
    button.backgroundColor = [UIColor colorWithRed:(59.0/255.0) green:(89.0/255.0) blue:(152.0/255.0) alpha:1.0];
    [button setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:@"NeutraText-Demi" size:18];
    [loginView addSubview:button];
    
    [self.view addSubview:loginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginWithFacebook {
    if (!accountStore) {
        accountStore = [[ACAccountStore alloc] init];
    }
    
    ACAccountType *facebookTypeAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                            options:@{ACFacebookAppIdKey: @"285691838260452", ACFacebookPermissionsKey: @[@"email"]}
                                            completion:^(BOOL granted, NSError *error){
                                            if (granted) {
                                               NSArray *accounts = [accountStore accountsWithAccountType:facebookTypeAccount];
                                               ACAccount *facebookAccount = [accounts lastObject];
                                               
                                               NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
                                               NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                               [params setValue:@"id,first_name,last_name,email,gender" forKey:@"fields"];
                                               SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                         requestMethod:SLRequestMethodGET
                                                                                                   URL:meurl
                                                                                            parameters:params];
                                               merequest.account = facebookAccount;
                                               
                                               [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                   NSDictionary *d = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
                                                   [[NSUserDefaults standardUserDefaults] setObject:[d objectForKey:@"id"] forKey:@"fbid"];
                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@ %@",[d objectForKey:@"first_name"],[d objectForKey:@"last_name"]] forKey:@"fbname"];
                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[d objectForKey:@"id"]] forKey:@"fbprofile"];
                                                   
                                                   NSLog(@"facebook dawg %@",d);
                                                   [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
                                               }];
                                           } else {
                                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please allow CPW 2018 access to your Facebook account in the settings app." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                                               [alertView show];
                                               NSLog(@"Error = %@", error);
                                           }
                                       }];
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
