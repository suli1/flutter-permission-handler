//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "PhotoPermissionStrategy.h"

#if PERMISSION_PHOTOS

@implementation PhotoPermissionStrategy
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [PhotoPermissionStrategy permissionStatus];
}

- (ServiceStatus)checkServiceStatus:(PermissionGroup)permission {
    return ServiceStatusNotApplicable;
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler {
    PermissionStatus status = [self checkPermissionStatus:permission];

    if (status != PermissionStatusNotDetermined) {
        completionHandler(status);
        return;
    }

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
        completionHandler([PhotoPermissionStrategy determinePermissionStatus:authorizationStatus]);
    }];
}

+ (PermissionStatus)permissionStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *))
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];

    return [PhotoPermissionStrategy determinePermissionStatus:status];
}

+ (PermissionStatus)determinePermissionStatus:(PHAuthorizationStatus)authorizationStatus {
    switch (authorizationStatus) {
        case PHAuthorizationStatusNotDetermined:
            return PermissionStatusNotDetermined;
        case PHAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case PHAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
        default:// iOS14中<PHAuthorizationStatusLimited>当做<PHAuthorizationStatusDenied>来处理
            return PermissionStatusDenied;
    }

    return PermissionStatusNotDetermined;
}

@end

#else

@implementation PhotoPermissionStrategy
@end

#endif
