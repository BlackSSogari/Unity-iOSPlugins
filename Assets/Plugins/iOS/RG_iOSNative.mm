#include <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/types.h>
//---------------------------------------------
#include <sys/xattr.h>
//---------------------------------------------
#include <mach/host_info.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>
#include <mach/processor_info.h>

#import "RG_iOSNative.h"

@implementation CaptureHelper

static CaptureHelper *captureHelper = nil;

+ (CaptureHelper*)sharedInstance
{
    if (captureHelper == nil)
    {
        captureHelper = [[self alloc] init];
    }
    
    return captureHelper;
}

- (id)init
{
    if(captureHelper != nil)
    {
        return  captureHelper;
    }
    
    self = [super init];
    if(self)
    {
        captureHelper = self;
    }
    
    return self;
}

- (NSString *)getDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [paths objectAtIndex:0];
}

- (void) saveToCameraRoll:(NSString *)media
{
    NSData *imageData = [[NSData alloc] initWithBase64Encoding:media];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
#if UNITY_VERSION < 500
    [imageData release];
#endif
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

@end

extern "C"
{
    void CaptureToCameraRoll(const char *fileName)
    {
        NSString *file = [NSString stringWithUTF8String:(fileName)];
        NSString *filePath = [[[CaptureHelper sharedInstance] getDocumentDirectory] stringByAppendingString:file];
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    void SaveToCameraRoll(char* encodedMedia)
    {
        NSString *media;
        if (encodedMedia != NULL)
        {
            media = [NSString stringWithUTF8String: encodedMedia];
        }
        else
        {
            media = [NSString stringWithUTF8String: ""];
        }
        
        [[CaptureHelper sharedInstance] saveToCameraRoll:media];
    }
}






@implementation RG_iOSNativeUtility

static RG_iOSNativeUtility * rg_iOSNativeUtility = nil;

+ (RG_iOSNativeUtility *)sharedInstance {
    
    if (rg_iOSNativeUtility == nil)  {
        rg_iOSNativeUtility = [[self alloc] init];
    }
    
    return rg_iOSNativeUtility;
}

- (id)init
{
    if(rg_iOSNativeUtility != nil)
    {
        return  rg_iOSNativeUtility;
    }
    
    self = [super init];
    if(self)
    {
        rg_iOSNativeUtility = self;
    }
    
    return self;
}

+ (BOOL) IsIPad 
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return true;
    } else {
        return false;
    }
}

+ (BOOL) IsIPhone 
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return true;
    } else {
        return false;
    }
}

+ (int) majorIOSVersion {
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    return [[vComp objectAtIndex:0] intValue];
}

+ (bool) checkSystemVersion:(NSString*) ver
{
    /*
     // System Versioning Preprocessor Macros
     #define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
     #define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
     #define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
     #define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
     #define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
     
     // Usage
     if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
     ...
     }
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
     ...
     }
     */
    if ([[[UIDevice currentDevice] systemVersion] compare:ver options:NSNumericSearch] != NSOrderedAscending)
    {
        return true;
    }
    
    return false;
}

#pragma mark - device detect utils

+ (int) DetectIPhoneGroup
{
    // 0 : under and iPhone 4
    // 1 : iPhone5
    // 2 : iPhone6/7/8
    // 3 : iPhoneX
    
    int retValue = 0;
    NSString *platform = [self platform];
    
    // ------------- iPhone ---------------------------
    if([platform isEqualToString:@"iPhone5,1"])
    {
        // iPhone 5(A1428)
        retValue = 1;
    }
    else if([platform isEqualToString:@"iPhone5,2"])
    {
        // iPhone 5(A1429)
        retValue = 1;
    }
    else if([platform isEqualToString:@"iPhone5,3"])
    {
        // iPhone 5C(A1456/A1532)
        retValue = 1;
    }
    else if([platform isEqualToString:@"iPhone5,4"])
    {
        // iPhone 5C(A1507/A1516/A1529)
        retValue = 1;
    }
    else if([platform isEqualToString:@"iPhone6,1"])
    {
        // iPhone 5S(A1433/A1453)
        retValue = 1;
    }
    else if([platform isEqualToString:@"iPhone6,2"])
    {
        // iPhone 5S(A1457/A1518/A1530)
        retValue = 1;
    }
    else if ([platform isEqualToString:@"iPhone7,1"])
    {
        // iPhone 6 Plus
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone7,2"])
    {
        // iPhone 6
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone8,1"])
    {
        // iPhone 6S
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone8,2"])
    {
        // iPhone 6S Plus
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone8,4"])
    {
        // iPhone SE
        retValue = 1;
    }
    else if ([platform isEqualToString:@"iPhone9,1"])
    {
        // iPhone 7(A1660/A1779/A1780)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone9,2"])
    {
        // iPhone 7 Plus(A1661/A1785/A1786)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone9,3"])
    {
        // iPhone 7(A1778)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone9,4"])
    {
        // iPhone 7 Plus(A1784)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone10,1"])
    {
        // iPhone 8(A1863/A1906)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone10,2"])
    {
        // iPhone 8 Plus(A1864/A1898)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone10,3"])
    {
        // iPhone X(A1865/A1902)
        retValue = 3;
    }
    else if ([platform isEqualToString:@"iPhone10,4"])
    {
        // iPhone 8(A1905)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone10,5"])
    {
        // iPhone 8 Plus(A1897)
        retValue = 2;
    }
    else if ([platform isEqualToString:@"iPhone10,6"])
    {
        // iPhone X(A1901)
        retValue = 3;
    }
    
    return retValue;
}

+ (NSString*) DetectDevice:(BOOL)detail
{
    NSString *pReturnString = @"Unknown";
    
    if( !detail )
    {
        // e.g. @"iPhone", @"iPod touch"
        pReturnString = [[UIDevice currentDevice] model];
    }
    else
    {
        NSString *platform = [self platform];
        
        // ------------- iPhone ---------------------------
        if ([platform isEqualToString:@"iPhone1,1"])
        {
            pReturnString = @"iPhone 1G";
        }
        else if ([platform isEqualToString:@"iPhone1,2"])
        {
            pReturnString = @"iPhone 3G";
        }
        else if ([platform isEqualToString:@"iPhone2,1"])
        {
            pReturnString = @"iPhone 3GS";
        }
        else if ([platform isEqualToString:@"iPhone3,1"])
        {
            pReturnString = @"iPhone 4(GSM)";
        }
        else if ([platform isEqualToString:@"iPhone3,3"])
        {
            pReturnString = @"iPhone 4(CDMA)";
        }
        else if ([platform isEqualToString:@"iPhone4,1"])
        {
            pReturnString = @"iPhone 4S";
        }
        else if([platform isEqualToString:@"iPhone5,1"])
        {
            pReturnString = @"iPhone 5(A1428)";
        }
        else if([platform isEqualToString:@"iPhone5,2"])
        {
            pReturnString = @"iPhone 5(A1429)";
        }
        else if([platform isEqualToString:@"iPhone5,3"])
        {
            pReturnString = @"iPhone 5C(A1456/A1532)";
        }
        else if([platform isEqualToString:@"iPhone5,4"])
        {
            pReturnString = @"iPhone 5C(A1507/A1516/A1529)";
        }
        else if([platform isEqualToString:@"iPhone6,1"])
        {
            pReturnString = @"iPhone 5S(A1433/A1453)";
        }
        else if([platform isEqualToString:@"iPhone6,2"])
        {
            pReturnString = @"iPhone 5S(A1457/A1518/A1530)";
        }
        else if ([platform isEqualToString:@"iPhone7,1"])
        {
            pReturnString = @"iPhone 6 Plus";
        }
        else if ([platform isEqualToString:@"iPhone7,2"])
        {
            pReturnString = @"iPhone 6";
        }
        else if ([platform isEqualToString:@"iPhone8,1"])
        {
            pReturnString = @"iPhone 6S";
        }
        else if ([platform isEqualToString:@"iPhone8,2"])
        {
            pReturnString = @"iPhone 6S Plus";
        }
        else if ([platform isEqualToString:@"iPhone8,4"])
        {
            pReturnString = @"iPhone SE";
        }
        else if ([platform isEqualToString:@"iPhone9,1"])
        {
            pReturnString = @"iPhone 7(A1660/A1779/A1780)";
        }
        else if ([platform isEqualToString:@"iPhone9,2"])
        {
            pReturnString = @"iPhone 7 Plus(A1661/A1785/A1786)";
        }
        else if ([platform isEqualToString:@"iPhone9,3"])
        {
            pReturnString = @"iPhone 7(A1778)";
        }
        else if ([platform isEqualToString:@"iPhone9,4"])
        {
            pReturnString = @"iPhone 7 Plus(A1784)";
        }
        else if ([platform isEqualToString:@"iPhone10,1"])
        {
            pReturnString = @"iPhone 8(A1863/A1906)";
        }
        else if ([platform isEqualToString:@"iPhone10,2"])
        {
            pReturnString = @"iPhone 8 Plus(A1864/A1898)";
        }
        else if ([platform isEqualToString:@"iPhone10,3"])
        {
            pReturnString = @"iPhone X(A1865/A1902)";
        }
        else if ([platform isEqualToString:@"iPhone10,4"])
        {
            pReturnString = @"iPhone 8(A1905)";
        }
        else if ([platform isEqualToString:@"iPhone10,5"])
        {
            pReturnString = @"iPhone 8 Plus(A1897)";
        }
        else if ([platform isEqualToString:@"iPhone10,6"])
        {
            pReturnString = @"iPhone X(A1901)";
        }
        
        // ------------- iPod ---------------------------
        else if ([platform isEqualToString:@"iPod1,1"])
        {
            pReturnString = @"iPod Touch 1G";
        }
        else if ([platform isEqualToString:@"iPod2,1"])
        {
            pReturnString = @"iPod Touch 2G";
        }
        else if ([platform isEqualToString:@"iPod3,1"])
        {
            pReturnString = @"iPod Touch 3G";
        }
        else if ([platform isEqualToString:@"iPod4,1"])
        {
            pReturnString = @"iPod Touch 4G";
        }
        else if ([platform isEqualToString:@"iPod5,1"])
        {
            pReturnString = @"iPod Touch 5G";
        }
        else if ([platform isEqualToString:@"iPod7,1"])
        {
            pReturnString = @"iPod Touch 6G";
        }
        
        // ------------- iPad ---------------------------
        else if ([platform isEqualToString:@"iPad1,1"])
        {
            pReturnString = @"iPad";
        }
        else if ([platform isEqualToString:@"iPad2,1"])
        {
            pReturnString = @"iPad 2 (WiFi)";
        }
        else if ([platform isEqualToString:@"iPad2,2"])
        {
            pReturnString = @"iPad 2 (GSM)";
        }
        else if ([platform isEqualToString:@"iPad2,3"])
        {
            pReturnString = @"iPad 2 (CDMA)";
        }
        else if ([platform isEqualToString:@"iPad2,4"])
        {
            pReturnString = @"iPad 2 (WiFi,Revised)";
        }
        else if ([platform isEqualToString:@"iPad2,5"])
        {
            pReturnString = @"iPad Mini (WiFi)";
        }
        else if ([platform isEqualToString:@"iPad2,6"])
        {
            pReturnString = @"iPad Mini(A1454)";
        }
        else if ([platform isEqualToString:@"iPad2,7"])
        {
            pReturnString = @"iPad Mini(A1455)";
        }
        
        else if ([platform isEqualToString:@"iPad3,1"])
        {
            pReturnString = @"iPad (3rd gen, Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad3,2"])
        {
            pReturnString = @"iPad (3rd gen, Wi-Fi+LTE Verizon)";
        }
        else if ([platform isEqualToString:@"iPad3,3"])
        {
            pReturnString = @"iPad (3rd gen, Wi-Fi+LTE AT&T)";
        }
        else if ([platform isEqualToString:@"iPad3,4"])
        {
            pReturnString = @"iPad (4th gen, Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad3,5"])
        {
            pReturnString = @"iPad (4th gen, A1459)";
        }
        else if ([platform isEqualToString:@"iPad3,6"])
        {
            pReturnString = @"iPad (4th gen, A1460)";
        }
        
        else if ([platform isEqualToString:@"iPad4,1"])
        {
            pReturnString = @"iPad Air (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad4,2"])
        {
            pReturnString = @"iPad Air (Wi-Fi+LTE)";
        }
        else if ([platform isEqualToString:@"iPad4,3"])
        {
            pReturnString = @"iPad Air (Rev)";
        }
        else if ([platform isEqualToString:@"iPad4,4"])
        {
            pReturnString = @"iPad mini 2 (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad4,5"])
        {
            pReturnString = @"iPad mini 2 (Wi-Fi+LTE)";
        }
        else if ([platform isEqualToString:@"iPad4,6"])
        {
            pReturnString = @"iPad mini 2 (Rev)";
        }
        else if ([platform isEqualToString:@"iPad4,7"])
        {
            pReturnString = @"iPad mini 3 (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad4,8"])
        {
            pReturnString = @"iPad mini 3 (A1600)";
        }
        else if ([platform isEqualToString:@"iPad4,9"])
        {
            pReturnString = @"iPad mini 3 (A1601)";
        }
        
        else if ([platform isEqualToString:@"iPad5,1"])
        {
            pReturnString = @"iPad mini 4 (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad5,2"])
        {
            pReturnString = @"iPad mini 4 (Wi-Fi+LTE)";
        }
        else if ([platform isEqualToString:@"iPad5,3"])
        {
            pReturnString = @"iPad Air 2 (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad5,4"])
        {
            pReturnString = @"iPad Air 2 (Wi-Fi+LTE)";
        }
        
        else if ([platform isEqualToString:@"iPad6,3"])
        {
            pReturnString = @"iPad Pro (9.7 inch) (Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad6,4"])
        {
            pReturnString = @"iPad Pro (9.7 inch) (Wi-Fi+LTE)";
        }
        else if ([platform isEqualToString:@"iPad6,7"])
        {
            pReturnString = @"iPad Pro (12.9 inch, Wi-Fi)";
        }
        else if ([platform isEqualToString:@"iPad6,8"])
        {
            pReturnString = @"iPad Pro (12.9 inch, Wi-Fi+LTE)";
        }
        else if ([platform isEqualToString:@"iPad6,11"])
        {
            pReturnString = @"iPad 9.7-Inch 5th Gen (Wi-Fi Only)";
        }
        else if ([platform isEqualToString:@"iPad6,12"])
        {
            pReturnString = @"iPad 9.7-Inch 5th Gen (Wi-Fi/Cellular)";
        }
        
        else if ([platform isEqualToString:@"iPad7,3"])
        {
            pReturnString = @"iPad Pro (10.5 inch, A1701)";
        }
        else if ([platform isEqualToString:@"iPad7,4"])
        {
            pReturnString = @"iPad Pro (10.5 inch, A1709)";
        }
        
        else if ([platform isEqualToString:@"i386"])
        {
            pReturnString = @"Simulator";
        }
        else
        {
            pReturnString = platform;
        }
    }
    
    printf("\n");
    NSLog(@"** 디바이스 플랫폼 **");
    NSLog(@"** %@ **",pReturnString);
    printf("\n");
    
    return pReturnString;
}

#pragma mark - sysctlbyname utils
+ (NSString *) getSysInfoByName:(const char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = (char*)malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    free(answer);
    return results;
}

+ (NSString *) platform
{
    NSString *pReturnString = [self getSysInfoByName:"hw.machine"];
    return pReturnString;
}

#pragma mark - free disk space check
+ (NSString *) commasForNumber: (long long) num
{
    if (num < 1000) return [NSString stringWithFormat:@"%lld", num];
    return    [[self commasForNumber:num/1000] stringByAppendingFormat:@",%03lld", (num % 1000)];
}

+ (long long) checkFreeDiskSpace
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fattributes = [fm attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    printf("** Check FreeDiskSpace **\n");
    printf("** System Total Disk Space : %s,   %s mb **\n",[[self commasForNumber:[[fattributes objectForKey:NSFileSystemSize] longLongValue]]UTF8String] , [[self commasForNumber:(([[fattributes objectForKey:NSFileSystemSize] longLongValue] / 1024) /1024) ]UTF8String]);
    printf("** System Free  Disk Space : %s,   %s mb **\n\n",[[self commasForNumber:[[fattributes objectForKey:NSFileSystemFreeSize] longLongValue]]UTF8String], [[self commasForNumber:(([[fattributes objectForKey:NSFileSystemFreeSize] longLongValue] / 1024) /1024) ]UTF8String]);
    
    //NSLog(@"System space: %@ byte, %@ mb", [self commasForNumber:[[fattributes objectForKey:NSFileSystemSize] longLongValue]], [self commasForNumber:(([[fattributes objectForKey:NSFileSystemSize] longLongValue] / 1024) /1024) ] );
    //NSLog(@"System free space: %@ byte, %@ mb", [self commasForNumber:[[fattributes objectForKey:NSFileSystemFreeSize] longLongValue]], [self commasForNumber:(([[fattributes objectForKey:NSFileSystemFreeSize] longLongValue] / 1024) /1024) ] );
    
    return [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue];
}

+ (BOOL) compareDiskSpace:(long long)value
{
    long long target = ( (value * 1024) * 1024 );
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fattributes = [fm attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    if( [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue] > target )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - do not backup attribute setting

+ (BOOL) addSkipBackupAttributeToItemURL:(NSString*)stringPath
{
    if ([self checkSystemVersion:@"5.1"])
    {
        NSURL* URL= [NSURL fileURLWithPath: stringPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
        {
            return false;
        }
        //assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else
    {
        if ([self checkSystemVersion:@"5.0.1"]) {
            //NSURL *url = [[NSURL alloc]initWithString:path];
            NSURL *URL = [NSURL fileURLWithPath:stringPath];
         
            if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
            {
                return false;
            }    

            const char* filePath = [[URL path] fileSystemRepresentation];
            
            const char* attrName = "com.apple.MobileBackup";
            u_int8_t attrValue = 1;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            /*
             if( url != nil )
             {
             [url release];
             url = nil;
             }
             */
            return result == 0;
        }
    }
    
    return true;
}

#pragma mark - Directory path
+ (NSString*) documentsPath:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSLog(@"DocumentDirectory : %@",documentDirectory);
    
    return [documentDirectory stringByAppendingPathComponent:filename];
}

+ (NSString*) cachesPath:(NSString*)filename
{
    NSArray *cachpaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachDirectory = [cachpaths objectAtIndex:0];
    NSLog(@"CachesDirectory : %@",cachDirectory);
    
    return [cachDirectory stringByAppendingPathComponent:filename];
}

+ (NSString*) temporaryPath:(NSString*)filename
{
    NSString *temporaryDirectory = NSTemporaryDirectory();
    
    NSLog(@"temporaryDirectory : %@",temporaryDirectory);
    
    return [temporaryDirectory stringByAppendingPathComponent:filename];
}

+ (NSString*) datafilePath:(NSString*)filename
{
#ifdef CACHES_DIRECTORY_PATH
    return [self cachesPath:filename];
#else
    return [self documentsPath:filename];
#endif
}

@end

extern "C"
{
    const char* getCFBundleVersion()
    {
        return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] UTF8String];
    }
    
    void CopyToClipboard(const char* c)
    {
        [UIPasteboard generalPasteboard].string = [NSString stringWithCString: c encoding:NSUTF8StringEncoding];
    }
    
    const char* PasteFromClipboard()
    {
        return [[UIPasteboard generalPasteboard].string UTF8String];
    }
    
    bool receiveUserID(const char* userid)
    {
        APPGUARD_SET_USER_ID(userid);
        return true;
    }
    
    const char* getAppGuardUUID()
    {
        return APPGUARD_GET_UDID;
    }
    
    const char* getDeeplinkURL()
    {
        NSString *deeplink = [[NSUserDefaults standardUserDefaults] objectForKey:@"KakaoDeeplink"];
        if (deeplink == NULL)
            return "";
        return [deeplink UTF8String];
        //UnitySendMessage("[iOSNativeManager]", "OnDeepLinkCallback",[deeplink UTF8String]);
    }
    
    int getDeviceGroup()
    {
        return [RG_iOSNativeUtility DetectIPhoneGroup];
    }
    
    const char* getDocumentDirectoryPath(const char* path)
    {
        return [[RG_iOSNativeUtility documentsPath:[NSString stringWithCString:path encoding:NSUTF8StringEncoding]] UTF8String];
    }

    bool getIsIphone()
    {
        return [RG_iOSNativeUtility IsIPhone];
    }
}



@implementation ReachabilityHelper

static ReachabilityHelper *reachabilityHelper = nil;

+ (ReachabilityHelper*)sharedInstance
{
    if (reachabilityHelper == nil)
    {
        reachabilityHelper = [[self alloc] init];
    }
    
    return reachabilityHelper;
}

- (id)init
{
    if(reachabilityHelper != nil)
    {
        return  reachabilityHelper;
    }
    
    self = [super init];
    if(self)
    {
        reachabilityHelper = self;
    }
    
    return self;
}

- (void) CheckReachAbility
{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self updateInterfaceWithReachability:self.internetReachability];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.internetReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        //BOOL connectionRequired = [reachability connectionRequired];
        NSString* statusString = @"";
        NSString* netStatusString = @"";
        
        switch (netStatus)
        {
            case NotReachable:        {
                statusString = @"Access Not Available";
                netStatusString = @"NotReachable";
                break;
            }
                
            case ReachableViaWWAN:        {
                statusString = @"Reachable WWAN";
                netStatusString = @"WWAN";
                break;
            }
            case ReachableViaWiFi:        {
                statusString= @"Reachable WiFi";
                netStatusString = @"WiFi";
                break;
            }
        }
        
        // if (connectionRequired)
        // {
        //     NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        //     statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
        // }
        
        //NSLog(@"Reachability Changed : %@", statusString);
        
        UnitySendMessage("[iOSNativeManager]", "OnReachabilityChanged", [netStatusString UTF8String]);
    }
    
}

@end

extern "C"
{
    void CheckStartReachability()
    {
        [[ReachabilityHelper sharedInstance] CheckReachAbility];
    }
}

