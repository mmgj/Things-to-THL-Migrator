//
//  main.m
//  Things Migrator
//
//  Created by Martin Jacobsen on 13.12.09.
//  Copyright Creuna 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, char *argv[])
{
	[[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];

	return NSApplicationMain(argc, (const char **) argv);
}
