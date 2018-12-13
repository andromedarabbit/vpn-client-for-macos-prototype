//
//  ViewController.h
//  VPN_Client_for_macOS_Prototype
//
//  Created by Nicholas Choi on 14/12/2018.
//  Copyright © 2018 Org1. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

typedef NS_ENUM(NSUInteger, WireguardCommand) {
    WireguardCommandUp,
    WireguardCommandDown
};

- (BOOL)checkStatus;
- (void)refreshStatus;
- (void)updateStatus:(BOOL)isTunneled;
- (void)manipulateTunnel:(WireguardCommand)command;

@property (retain) NSFileManager *fileManager;

@property (weak) IBOutlet NSSecureTextField *adminPasswordTextField;
@property (weak) IBOutlet NSTextField *currentStatusTextField;
@property (weak) IBOutlet NSButton *tunnelingSwitcherButton;

@end

