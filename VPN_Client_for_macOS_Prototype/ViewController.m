//
//  ViewController.m
//  VPN_Client_for_macOS_Prototype
//
//  Created by Nicholas Choi on 14/12/2018.
//  Copyright © 2018 Org1. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _fileManager = [[NSFileManager alloc] init];
    [self refreshStatus];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (IBAction)onTunnelingSwitcherButtonPushed:(NSButton *)sender {
    if ([_currentStatusTextField.stringValue isEqualToString:@"NOT TUNNELED"] == TRUE) {
        if ([self checkStatus] == FALSE) {
            // make a tunnel now
            [self manipulateTunnel:WireguardCommandUp];
        }
    } else {
        if ([self checkStatus] == TRUE) {
            // close the tunnel now
            [self manipulateTunnel:WireguardCommandDown];
        }
    }
    [self refreshStatus];
}

- (BOOL)checkStatus {
    return [_fileManager fileExistsAtPath:@"/var/run/wireguard/us.name"];
}

- (void)refreshStatus {
    BOOL isTunneled = [self checkStatus];
    [self updateStatus:isTunneled];
}

- (void)updateStatus:(BOOL)isTunneled {
    if (isTunneled == TRUE) {
        [_currentStatusTextField setStringValue:@"TUNNELED"];
        [_tunnelingSwitcherButton setTitle:@"CLOSE THE TUNNEL"];
    } else {
        [_currentStatusTextField setStringValue:@"NOT TUNNELED"];
        [_tunnelingSwitcherButton setTitle:@"MAKE A TUNNEL"];
    }
}

- (void)manipulateTunnel:(WireguardCommand)command {
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"us" ofType:@"conf"];
    NSString *resourcePath = [confPath substringWithRange:NSMakeRange(0, confPath.length - 8)];
    NSString *parameter;
    
    switch (command) {
        case WireguardCommandUp:
            parameter = @"up";
            break;
            
        case WireguardCommandDown:
            parameter = @"down";
            break;
            
        default:
            // unknown command
            return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"export PATH=\"%@:$PATH\"; sudo -S bash -c \"wg-quick %@ %@\"", resourcePath, parameter, confPath], nil]];
    NSPipe *inputPipe = [[NSPipe alloc] init];
    [task setStandardInput:inputPipe];
    [task launch];
    
    NSFileHandle *fileHandle = [inputPipe fileHandleForWriting];
    [fileHandle writeData:[[NSString stringWithFormat:@"%@\n", [_adminPasswordTextField stringValue]] dataUsingEncoding:NSASCIIStringEncoding]];
    [fileHandle closeFile];
    
    [task waitUntilExit];
}

@end
