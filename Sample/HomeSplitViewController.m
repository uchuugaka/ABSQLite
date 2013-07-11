//
//  HomeViewController.m
//  MobileApp
//
//  Created by Aaron Bratcher on 12/05/2012.
//  Copyright (c) 2012 Market Force. All rights reserved.
//

#import "HomeSplitViewController.h"

@interface HomeSplitViewController ()<UISplitViewControllerDelegate>

@end

@implementation HomeSplitViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.delegate = self;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
	return NO;
}


@end
