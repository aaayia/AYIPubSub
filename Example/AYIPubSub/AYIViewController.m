//
//  AYIViewController.m
//  AYIPubSub
//
//  Created by aaayia on 09/19/2018.
//  Copyright (c) 2018 aaayia. All rights reserved.
//

#import "AYIViewController.h"
#import "NSObject+AYIPubSub.h"

@interface AYIViewController ()

@end

@implementation AYIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [ self publish:@"viewDidLoad" withObject:@{@"view": self.view}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
