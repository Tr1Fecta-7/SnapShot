#import <Photos/Photos.h>
#import <AudioToolbox/AudioToolbox.h>

extern "C" UIImage *_UICreateScreenUIImageWithRotation(BOOL rotate);

static void sendNotificationForScreenshot() {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"takeScreenshotNow" object:nil];
}

%hook HookWindow

-(id)initWithDisplayConfiguration:(id)arg1{
    if ((self = %orig)) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeSS) name:@"takeScreenshotNow" object:nil];
    }
    return self;
}


%new
-(void)takeSS {
    // get image data
	UIImage *previewImage = _UICreateScreenUIImageWithRotation(TRUE);
    NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(previewImage)];

	if (imgData == nil) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{	
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
			PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
		    [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imgData options:options];

		} completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"[SnapShot]: SCREENSHOT SAVED!!!, success: %d", success);
			}];
	});
}

%end


%hook SpringBoard


-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 
{
	int type = arg1.allPresses.allObjects[0].type; 
	int force = arg1.allPresses.allObjects[0].force;

    NSLog(@"[SnapShot]: Pressed: %d - Force: %d", type, force);

	// type = 101 -> Home button
	// type = 102 -> vol up
	// type = 103 -> vol down
	// type = 104 -> Power button
    

	// force = 0 -> button released
	// force = 1 -> button pressed
	if ([arg1.allPresses.allObjects count] <= 1) return %orig;
	if (type == 103 && force == 1 && arg1.allPresses.allObjects[1].type == 102 && arg1.allPresses.allObjects[1].force == 1) // volume up + down
	{
		sendNotificationForScreenshot();
        AudioServicesPlaySystemSound(1519);
		return NO;
	}

	return %orig;
}

%end

%ctor {
    Class classToHook;
    if (@available(iOS 13, *)) {
        classToHook = NSClassFromString(@"UIRootSceneWindow");
    }
    else {
        classToHook = NSClassFromString(@"FBRootWindow");
    }
	%init(HookWindow=classToHook);
}