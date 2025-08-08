#!/usr/bin/env python3
"""
Script fix project.pbxproj bị corrupt
"""

import os
import re
import subprocess
import sys

def backup_pbxproj():
    """Backup project.pbxproj hiện tại"""
    print("🔧 Backing up current project.pbxproj...")
    
    pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
    backup_path = 'ios/Runner.xcodeproj/project.pbxproj.backup'
    
    if os.path.exists(pbxproj_path):
        with open(pbxproj_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        with open(backup_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("✅ project.pbxproj đã được backup")
    else:
        print("❌ project.pbxproj không tồn tại")

def create_clean_pbxproj():
    """Tạo project.pbxproj sạch với iOS 15.0"""
    print("🔧 Creating clean project.pbxproj with iOS 15.0...")
    
    pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
    
    # Tạo project.pbxproj cơ bản
    clean_content = '''// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		1498D2341E8E89220040F4C2 /* GeneratedPluginRegistrant.cc in Sources */ = {isa = PBXBuildFile; fileRef = 1498D2321E8E89220040F4C2 /* GeneratedPluginRegistrant.cc */; };
		3B3967161E833CAA004F5970 /* AppFrameworkInfo.plist in Resources */ = {isa = PBXBuildFile; fileRef = 3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */; };
		74858FAF1ED6DC5600515810 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 74858FAE1ED6DC5600515810 /* AppDelegate.swift */; };
		97C146FC1CF9000F007C117D /* Main.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FA1CF9000F007C117D /* Main.storyboard */; };
		97C146FE1CF9000F007C117D /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FD1CF9000F007C117D /* Assets.xcassets */; };
		97C147011CF9000F007C117D /* LaunchScreen.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		1498D2321E8E89220040F4C2 /* GeneratedPluginRegistrant.cc */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.cpp.cpp; name = GeneratedPluginRegistrant.cc; path = Flutter/GeneratedPluginRegistrant.cc; sourceTree = "<group>"; };
		3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; name = AppFrameworkInfo.plist; path = Flutter/AppFrameworkInfo.plist; sourceTree = "<group>"; };
		74858FAE1ED6DC5600515810 /* AppDelegate.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
		7AFA3C8E1D35360C0083082E /* Runner.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; name = Runner.xcconfig; path = Flutter/Runner.xcconfig; sourceTree = "<group>"; };
		97C146E61CF9000F007C117D /* Runner.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Runner.app; sourceTree = BUILT_PRODUCTS_DIR; };
		97C146F21CF9000F007C117D /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
		97C146FA1CF9000F007C117D /* Main.storyboard */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; path = Main.storyboard; sourceTree = "<group>"; };
		97C146FD1CF9000F007C117D /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; path = LaunchScreen.storyboard; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		97C146EC1CF9000F007C117D /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		97C146E61CF9000F007C117D = {
			isa = PBXGroup;
			children = (
				97C146F11CF9000F007C117D /* Runner */,
				97C146F01CF9000F007C117D /* Products */,
				3B06AD1E1E4923F5004D2608 /* Frameworks */,
			);
			sourceTree = "<group>";
		};
		97C146F01CF9000F007C117D /* Products */ = {
			isa = PBXGroup;
			children = (
				97C146E61CF9000F007C117D /* Runner.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		97C146F11CF9000F007C117D /* Runner */ = {
			isa = PBXGroup;
			children = (
				97C146FA1CF9000F007C117D /* Main.storyboard */,
				97C146FD1CF9000F007C117D /* Assets.xcassets */,
				97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */,
				74858FAE1ED6DC5600515810 /* AppDelegate.swift */,
				97C146F21CF9000F007C117D /* Info.plist */,
				1498D2321E8E89220040F4C2 /* GeneratedPluginRegistrant.cc */,
				3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */,
			);
			path = Runner;
			sourceTree = "<group>";
		};
		3B06AD1E1E4923F5004D2608 /* Frameworks */ = {
			isa = PBXGroup;
			children = (
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		97C146ED1CF9000F007C117D /* Runner */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 97C147031CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */;
			buildPhases = (
				9740EEB61CF901F6004384FC /* Run Script */,
				97C146EA1CF9000F007C117D /* Sources */,
				97C146EB1CF9000F007C117D /* Frameworks */,
				97C146EC1CF9000F007C117D /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Runner;
			productName = Runner;
			productReference = 97C146E61CF9000F007C117D /* Runner.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		97C146E71CF9000F007C117D /* Project object */ = {
			isa = PBXProject;
			attributes = {
				LastUpgradeCheck = 1020;
				ORGANIZATIONNAME = "";
				TargetAttributes = {
					97C146ED1CF9000F007C117D = {
						CreatedOnToolsVersion = 7.3.1;
						LastSwiftMigration = 1100;
					};
				};
			};
			buildConfigurationList = 97C146EA1CF9000F007C117D /* Build configuration list for PBXProject "Runner" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = 97C146E61CF9000F007C117D;
			productRefGroup = 97C146F01CF9000F007C117D /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				97C146ED1CF9000F007C117D /* Runner */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		97C146EC1CF9000F007C117D /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				97C147011CF9000F007C117D /* LaunchScreen.storyboard in Resources */,
				3B3967161E833CAA004F5970 /* AppFrameworkInfo.plist in Resources */,
				97C146FE1CF9000F007C117D /* Assets.xcassets in Resources */,
				97C146FC1CF9000F007C117D /* Main.storyboard in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXShellScriptBuildPhase section */
		9740EEB61CF901F6004384FC /* Run Script */ = {
			isa = PBXShellScriptBuildPhase;
			alwaysOutOfDate = 1;
			buildActionMask = 2147483647;
			files = (
			);
			inputFileListPaths = (
			);
			inputPaths = (
				"${SRCROOT}/../build/ios/Debug-iphoneos/Runner.app.dSYM",
				"${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/dSYMs/Runner.app.dSYM",
			);
			name = "Run Script";
			outputFileListPaths = (
			);
			outputPaths = (
				"$(DERIVED_FILE_DIR)/Runner.app.dSYM",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "/bin/sh \"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\" embed_and_thin";
		};
/* End PBXShellScriptBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		97C146EA1CF9000F007C117D /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				74858FAF1ED6DC5600515810 /* AppDelegate.swift in Sources */,
				1498D2341E8E89220040F4C2 /* GeneratedPluginRegistrant.cc in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		249021D3217E4FDB00AE95B9 /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Runner.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_PROFILING = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
				DEVELOPMENT_TEAM = "";
				ENABLE_BITCODE = NO;
				INFOPLIST_FILE = Runner/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = iphoneos;
				SDKROOT = iphoneos;
				VALIDATE_PRODUCT = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Profile;
		};
		249021D4217E4FDB00AE95B9 /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Runner.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_PROFILING = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
				DEVELOPMENT_TEAM = "";
				ENABLE_BITCODE = NO;
				INFOPLIST_FILE = Runner/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = iphoneos;
				SDKROOT = iphoneos;
				VALIDATE_PRODUCT = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Release;
		};
		97C147031CF9000F007C117D /* Debug */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Runner.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_PROFILING = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
				DEVELOPMENT_TEAM = "";
				ENABLE_BITCODE = NO;
				INFOPLIST_FILE = Runner/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = iphoneos;
				SDKROOT = iphoneos;
				VALIDATE_PRODUCT = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Debug;
		};
		97C147041CF9000F007C117D /* Profile */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Runner.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_PROFILING = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
				DEVELOPMENT_TEAM = "";
				ENABLE_BITCODE = NO;
				INFOPLIST_FILE = Runner/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = iphoneos;
				SDKROOT = iphoneos;
				VALIDATE_PRODUCT = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Profile;
		};
		97C147051CF9000F007C117D /* Release */ = {
			isa = XCBuildConfiguration;
			baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Runner.xcconfig */;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CLANG_ENABLE_PROFILING = YES;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
				DEVELOPMENT_TEAM = "";
				ENABLE_BITCODE = NO;
				INFOPLIST_FILE = Runner/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 15.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.studybuddy.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				PROVISIONING_PROFILE_SPECIFIER = "";
				SUPPORTED_PLATFORMS = iphoneos;
				SDKROOT = iphoneos;
				VALIDATE_PRODUCT = YES;
				SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
				SWIFT_VERSION = 5.0;
				VERSIONING_SYSTEM = "apple-generic";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		97C146EA1CF9000F007C117D /* Build configuration list for PBXProject "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				97C147031CF9000F007C117D /* Debug */,
				249021D3217E4FDB00AE95B9 /* Profile */,
				249021D4217E4FDB00AE95B9 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		97C147031CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				97C147041CF9000F007C117D /* Debug */,
				97C147051CF9000F007C117D /* Profile */,
				97C147051CF9000F007C117D /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = 97C146E71CF9000F007C117D /* Project object */;
}
'''
    
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(clean_content)
    
    print("✅ Clean project.pbxproj đã được tạo với iOS 15.0")

def create_simple_codemagic():
    """Tạo codemagic.yaml đơn giản"""
    print("🔧 Creating simple codemagic.yaml...")
    
    codemagic_content = """workflows:
  ios-workflow:
    name: iOS Build (Clean pbxproj)
    environment:
      xcode: 14.3
      cocoapods: default
    scripts:
      - name: Setup
        script: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
      - name: Clean
        script: |
          rm -rf ios/Pods
          rm -f ios/Podfile.lock
          flutter clean
      - name: Install pods
        script: |
          cd ios
          pod install --repo-update
      - name: Build iOS Framework
        script: |
          flutter build ios-framework --output=build/ios-framework
    artifacts:
      - build/ios-framework/
    publishing:
      app_store_connect:
        api_key: $APP_STORE_CONNECT_PRIVATE_KEY
        key_id: $APP_STORE_CONNECT_KEY_IDENTIFIER
        issuer_id: $APP_STORE_CONNECT_ISSUER_ID
        submit_to_testflight: false
"""
    
    with open('codemagic.yaml', 'w') as f:
        f.write(codemagic_content)
    
    print("✅ codemagic.yaml đã được tạo")

def create_guide():
    """Tạo hướng dẫn fix"""
    print("🔧 Creating fix guide...")
    
    guide_content = """# 🚨 FIX PBXPROJ CORRUPT ERROR

## 📋 **Vấn đề hiện tại:**
```
Failed to parse pbxproject /Users/builder/clone/ios/Runner.xcodeproj/project.pbxproj
```

## 🔧 **Giải pháp:**

### **1. Đã thực hiện:**
- ✅ **Backup** project.pbxproj hiện tại
- ✅ **Tạo mới** project.pbxproj sạch
- ✅ **Cấu hình** iOS 15.0 minimum
- ✅ **Bundle ID**: com.studybuddy.app

### **2. Cấu hình mới:**
- **iOS Deployment Target**: 15.0
- **Bundle ID**: com.studybuddy.app
- **Xcode Version**: 14.3
- **Build Type**: Framework-only

## 📱 **Workflows:**

| File | Mục đích |
|------|----------|
| **codemagic.yaml** | Framework build (mặc định) |
| **project.pbxproj** | Clean iOS project file |

## ⚠️ **Lưu ý:**

### **Backup:**
- File cũ: `ios/Runner.xcodeproj/project.pbxproj.backup`
- File mới: `ios/Runner.xcodeproj/project.pbxproj`

### **Test Steps:**
1. **Build test** với project.pbxproj mới
2. **Check** không còn lỗi parse
3. **Verify** iOS 15.0 settings
4. **Test** framework build

## 🎯 **Expected Result:**

- ✅ Không còn lỗi "Failed to parse pbxproject"
- ✅ Build thành công với iOS 15.0
- ✅ Framework được tạo
- ✅ Sẵn sàng cho TestFlight
"""
    
    with open('PBXPROJ_FIX_GUIDE.md', 'w') as f:
        f.write(guide_content)
    
    print("✅ PBXPROJ_FIX_GUIDE.md đã được tạo")

def main():
    """Main function"""
    print("🚨 FIXING PBXPROJ CORRUPT ERROR")
    print("=" * 60)
    
    print("\n📋 Vấn đề:")
    print("1. Lỗi: 'Failed to parse pbxproject'")
    print("2. Nguyên nhân: project.pbxproj bị corrupt")
    print("3. Giải pháp: Tạo mới project.pbxproj sạch")
    
    print("\n🔧 Thực hiện fixes...")
    
    # Backup current file
    backup_pbxproj()
    
    # Create clean pbxproj
    create_clean_pbxproj()
    
    # Create simple codemagic
    create_simple_codemagic()
    
    # Create guide
    create_guide()
    
    print("\n" + "=" * 60)
    print("✅ PBXPROJ FIXES ĐÃ HOÀN THÀNH!")
    
    print("\n📋 Bước tiếp theo:")
    print("1. Push code lên GitHub:")
    print("   git add .")
    print("   git commit -m 'Fix pbxproj corrupt: create clean project.pbxproj'")
    print("   git push origin main")
    print("\n2. Test build:")
    print("   - Không còn lỗi parse")
    print("   - Framework build thành công")
    print("   - iOS 15.0 settings hoạt động")
    
    print("\n🔍 Files:")
    print("- project.pbxproj: Clean iOS project file")
    print("- project.pbxproj.backup: Backup file cũ")
    print("- codemagic.yaml: Simple framework build")

if __name__ == "__main__":
    main() 