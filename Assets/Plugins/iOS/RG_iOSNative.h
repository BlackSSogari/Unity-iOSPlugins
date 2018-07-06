#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <AppGuardCore/AppGuard.h>
#import "Reachability.h"

@interface CaptureHelper : NSObject

+ (CaptureHelper *)sharedInstance;

- (NSString *)getDocumentDirectory;
- (void) saveToCameraRoll:(NSString *)media;

@end



@interface RG_iOSNativeUtility : NSObject

+ (RG_iOSNativeUtility *)sharedInstance;

+ (BOOL) IsIPad;
+ (BOOL) IsIPhone;
+ (int) majorIOSVersion;
+ (bool) checkSystemVersion:(NSString*) ver;

#pragma mark - device detect utils
+ (int) DetectIPhoneGroup;
+ (NSString*) DetectDevice:(BOOL)detail;

#pragma mark - sysctlbyname utils
+ (NSString *) platform;
+ (NSString *) getSysInfoByName:(const char *)typeSpecifier;

#pragma mark - free disk space check
+ (NSString *) commasForNumber: (long long) num;
+ (long long) checkFreeDiskSpace;
+ (BOOL) compareDiskSpace:(long long)value;

#pragma mark - do not backup attribute setting
+ (BOOL) addSkipBackupAttributeToItemURL:(NSString*)path;

#pragma mark - Directory path
+ (NSString*) documentsPath:(NSString*)filename;
+ (NSString*) cachesPath:(NSString*)filename;
+ (NSString*) temporaryPath:(NSString*)filename;
+ (NSString*) datafilePath:(NSString*)filename;

@end





@interface ReachabilityHelper : NSObject

+ (ReachabilityHelper*)sharedInstance;

- (void) CheckReachAbility;

@property (nonatomic) Reachability *internetReachability;

@end
