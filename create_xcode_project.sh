#!/bin/bash

echo "Creating Xcode project for App Store submission..."

# Create Xcode project directory
PROJECT_NAME="ClipFlow"
PROJECT_DIR="${PROJECT_NAME}.xcodeproj"

mkdir -p "$PROJECT_DIR"

# Create proper project.pbxproj for Xcode
cat > "$PROJECT_DIR/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		AA0001 /* ClipboardManagerApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0001 /* ClipboardManagerApp.swift */; };
		AA0002 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0002 /* ContentView.swift */; };
		AA0003 /* ClipboardItem.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0003 /* ClipboardItem.swift */; };
		AA0004 /* ClipboardManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0004 /* ClipboardManager.swift */; };
		AA0005 /* HeaderView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0005 /* HeaderView.swift */; };
		AA0006 /* ClipboardItemView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0006 /* ClipboardItemView.swift */; };
		AA0007 /* MenuBarManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0007 /* MenuBarManager.swift */; };
		AA0008 /* PersistenceManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0008 /* PersistenceManager.swift */; };
		AA0009 /* HotkeyManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0009 /* HotkeyManager.swift */; };
		AA0010 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0010 /* SettingsView.swift */; };
		AA0011 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = BB0011 /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		CC0001 /* ClipFlow.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ClipFlow.app; sourceTree = BUILT_PRODUCTS_DIR; };
		BB0001 /* ClipboardManagerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ClipboardManagerApp.swift; sourceTree = "<group>"; };
		BB0002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		BB0003 /* ClipboardItem.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ClipboardItem.swift; sourceTree = "<group>"; };
		BB0004 /* ClipboardManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ClipboardManager.swift; sourceTree = "<group>"; };
		BB0005 /* HeaderView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HeaderView.swift; sourceTree = "<group>"; };
		BB0006 /* ClipboardItemView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ClipboardItemView.swift; sourceTree = "<group>"; };
		BB0007 /* MenuBarManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MenuBarManager.swift; sourceTree = "<group>"; };
		BB0008 /* PersistenceManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PersistenceManager.swift; sourceTree = "<group>"; };
		BB0009 /* HotkeyManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HotkeyManager.swift; sourceTree = "<group>"; };
		BB0010 /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsView.swift; sourceTree = "<group>"; };
		BB0011 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		BB0012 /* ClipFlow.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = ClipFlow.entitlements; sourceTree = "<group>"; };
		BB0013 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		DD0001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		EE0001 = {
			isa = PBXGroup;
			children = (
				EE0002 /* ClipFlow */,
				EE0003 /* Products */,
			);
			sourceTree = "<group>";
		};
		EE0002 /* ClipFlow */ = {
			isa = PBXGroup;
			children = (
				BB0001 /* ClipboardManagerApp.swift */,
				BB0002 /* ContentView.swift */,
				BB0003 /* ClipboardItem.swift */,
				BB0004 /* ClipboardManager.swift */,
				BB0005 /* HeaderView.swift */,
				BB0006 /* ClipboardItemView.swift */,
				BB0007 /* MenuBarManager.swift */,
				BB0008 /* PersistenceManager.swift */,
				BB0009 /* HotkeyManager.swift */,
				BB0010 /* SettingsView.swift */,
				BB0011 /* Assets.xcassets */,
				BB0012 /* ClipFlow.entitlements */,
				BB0013 /* Info.plist */,
			);
			path = ClipFlow;
			sourceTree = "<group>";
		};
		EE0003 /* Products */ = {
			isa = PBXGroup;
			children = (
				CC0001 /* ClipFlow.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		FF0001 /* ClipFlow */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = FF0002 /* Build configuration list for PBXNativeTarget "ClipFlow" */;
			buildPhases = (
				FF0003 /* Sources */,
				DD0001 /* Frameworks */,
				FF0004 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = ClipFlow;
			productName = ClipFlow;
			productReference = CC0001 /* ClipFlow.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		GG0001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {
					FF0001 = {
						CreatedOnToolsVersion = 16.0;
					};
				};
			};
			buildConfigurationList = GG0002 /* Build configuration list for PBXProject "ClipFlow" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = EE0001;
			productRefGroup = EE0003 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				FF0001 /* ClipFlow */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		FF0004 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AA0011 /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		FF0003 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AA0001 /* ClipboardManagerApp.swift in Sources */,
				AA0002 /* ContentView.swift in Sources */,
				AA0003 /* ClipboardItem.swift in Sources */,
				AA0004 /* ClipboardManager.swift in Sources */,
				AA0005 /* HeaderView.swift in Sources */,
				AA0006 /* ClipboardItemView.swift in Sources */,
				AA0007 /* MenuBarManager.swift in Sources */,
				AA0008 /* PersistenceManager.swift in Sources */,
				AA0009 /* HotkeyManager.swift in Sources */,
				AA0010 /* SettingsView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		HH0001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		HH0002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		HH0003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = ClipFlow/ClipFlow.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ClipFlow/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.clipflow.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		HH0004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = ClipFlow/ClipFlow.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = ClipFlow/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.clipflow.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		GG0002 /* Build configuration list for PBXProject "ClipFlow" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				HH0001 /* Debug */,
				HH0002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		FF0002 /* Build configuration list for PBXNativeTarget "ClipFlow" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				HH0003 /* Debug */,
				HH0004 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = GG0001 /* Project object */;
}
EOF

# Create Xcode scheme
mkdir -p "$PROJECT_DIR/xcshareddata/xcschemes"

cat > "$PROJECT_DIR/xcshareddata/xcschemes/ClipFlow.xcscheme" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "FF0001"
               BuildableName = "ClipFlow.app"
               BlueprintName = "ClipFlow"
               ReferencedContainer = "container:ClipFlow.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "FF0001"
            BuildableName = "ClipFlow.app"
            BlueprintName = "ClipFlow"
            ReferencedContainer = "container:ClipFlow.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "FF0001"
            BuildableName = "ClipFlow.app"
            BlueprintName = "ClipFlow"
            ReferencedContainer = "container:ClipFlow.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF

# Create ClipFlow directory with source files
mkdir -p ClipFlow

# Copy and modify source files for App Store
echo "Copying source files..."
cp appstore_version/Sources/* ClipFlow/

# Create App Store compatible entitlements
cat > ClipFlow/ClipFlow.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-only</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
EOF

# Copy Info.plist
cp Info.plist ClipFlow/

# Create Assets.xcassets structure
mkdir -p "ClipFlow/Assets.xcassets/AppIcon.appiconset"
mkdir -p "ClipFlow/Assets.xcassets/AccentColor.colorset"

# Generate app icons
swift generate_icon.swift
cp -r "build/ClipFlow.app/Contents/Resources/AppIcon.appiconset/"* "ClipFlow/Assets.xcassets/AppIcon.appiconset/"

# Create Contents.json for Assets.xcassets
cat > "ClipFlow/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AccentColor
cat > "ClipFlow/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Xcode project created successfully!"
echo ""
echo "Next steps:"
echo "1. Open ClipFlow.xcodeproj in Xcode"
echo "2. Set your Development Team in Build Settings"
echo "3. Update bundle identifier if needed"
echo "4. Archive the project (Product → Archive)"
echo "5. Upload to App Store Connect"