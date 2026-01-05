
function New-Pbid {
    param($prefix, $index)
    return "{0}{1:X4}" -f $prefix, $index
}

# Files Configuration
$swift_files_root = @(
    "AppLauncherManager.swift", "AppViewModel.swift", "BackgroundManager.swift", 
    "BriefingManager.swift", "CommandManager.swift", "ContentView.swift", 
    "EventManager.swift", "GroqTTSManager.swift", "HealthManager.swift", 
    "HeyJarvisApp.swift", "HomeManager.swift", "JarvisAI.swift", 
    "JarvisIntents.swift", "JarvisLiveActivity.swift", "MediaManager.swift", 
    "MemoryManager.swift", "MetaGlassesManager.swift", "MetaWorkflowController.swift", 
    "OfflineManager.swift", "OpenAITTSManager.swift", "ProtocolManager.swift", 
    "SettingsManager.swift", "SoundManager.swift", "SystemMonitor.swift", 
    "TextToSpeechManager.swift", "TimerManager.swift", "WakeWordDetector.swift", 
    "WatchSessionManager.swift", "WeatherManager.swift", "WidgetDataManager.swift"
)

$swift_files_models = @("Command.swift", "TTSError.swift")

$swift_files_views = @(
    "CommandHistoryView.swift", "CommandReferenceView.swift", 
    "ConversationHistoryView.swift", "JarvisMindView.swift", 
    "SettingsView.swift", "StatusView.swift"
)

$swift_files_components = @(
    "GlassesStatusView.swift", "HeaderView.swift", 
    "JarvisResponseView.swift", "TranscriptionView.swift"
)

$objects = @()
$file_refs = @{}

# --- PBXFileReference ---
# Root Swift Files
for ($i = 0; $i -lt $swift_files_root.Count; $i++) {
    $f = $swift_files_root[$i]
    $fid = New-Pbid "10000000000000000000" $i
    $file_refs[$f] = $fid
    $objects += "`t`t$fid /* $f */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $f; sourceTree = `"<group>`"; };"
}

# Models
for ($i = 0; $i -lt $swift_files_models.Count; $i++) {
    $f = $swift_files_models[$i]
    $fid = New-Pbid "10000000000000000001" $i
    $file_refs[$f] = $fid
    $objects += "`t`t$fid /* $f */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $f; sourceTree = `"<group>`"; };"
}

# Views
for ($i = 0; $i -lt $swift_files_views.Count; $i++) {
    $f = $swift_files_views[$i]
    $fid = New-Pbid "10000000000000000002" $i
    $file_refs[$f] = $fid
    $objects += "`t`t$fid /* $f */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $f; sourceTree = `"<group>`"; };"
}

# Components
for ($i = 0; $i -lt $swift_files_components.Count; $i++) {
    $f = $swift_files_components[$i]
    $fid = New-Pbid "10000000000000000003" $i
    $file_refs[$f] = $fid
    $objects += "`t`t$fid /* $f */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $f; sourceTree = `"<group>`"; };"
}

# Resources
$assets_id = "100000000000000000040000"
$plist_settings_id = "100000000000000000040001"
$objects += "`t`t$assets_id /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = `"<group>`"; };"
$objects += "`t`t$plist_settings_id /* JarvisVoiceSettings.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = JarvisVoiceSettings.plist; sourceTree = `"<group>`"; };"

# Info.plist
$info_plist_id = "100000000000000000050000"
$objects += "`t`t$info_plist_id /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = `"<group>`"; };"

# App Product
$app_product_id = "200000000000000000000000"
$objects += "`t`t$app_product_id /* HeyJarvisApp.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HeyJarvisApp.app; sourceTree = BUILT_PRODUCTS_DIR; };"

# --- PBXBuildFile (Sources) ---
$source_build_files = @()
$source_build_refs = @()
foreach ($f in $file_refs.Keys) {
    $fid = $file_refs[$f]
    $bid = $fid -replace "1000", "2000"
    $source_build_files += $bid
    $source_build_refs += "$bid /* $f in Sources */"
    $objects += "`t`t$bid /* $f in Sources */ = {isa = PBXBuildFile; fileRef = $fid /* $f */; };"
}

# --- PBXBuildFile (Resources) ---
$assets_build_id = $assets_id -replace "1000", "3000"
$plist_settings_build_id = $plist_settings_id -replace "1000", "3000"
$objects += "`t`t$assets_build_id /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = $assets_id /* Assets.xcassets */; };"
$objects += "`t`t$plist_settings_build_id /* JarvisVoiceSettings.plist in Resources */ = {isa = PBXBuildFile; fileRef = $plist_settings_id /* JarvisVoiceSettings.plist */; };"

# --- PBXGroup ---
$group_app_id = "400000000000000000000001"
$group_models_id = "400000000000000000000002"
$group_views_id = "400000000000000000000003"
$group_components_id = "400000000000000000000004"
$group_resources_id = "400000000000000000000005"
$group_main_id = "400000000000000000000000"
$group_products_id = "400000000000000000000006"

# Root Group Children
$root_children_str = ""
foreach ($f in $swift_files_root) {
    $root_children_str += "`t`t`t`t$($file_refs[$f]) /* $f */,`n"
}
$root_children_str += "`t`t`t`t$group_models_id /* Models */,`n"
$root_children_str += "`t`t`t`t$group_views_id /* Views */,`n"
$root_children_str += "`t`t`t`t$group_resources_id /* Resources */,`n"
$root_children_str += "`t`t`t`t$assets_id /* Assets.xcassets */,`n"
$root_children_str += "`t`t`t`t$info_plist_id /* Info.plist */,`n"

$objects += "`t`t$group_app_id /* HeyJarvisApp */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n$root_children_str`t`t`t);`n`t`t`tpath = HeyJarvisApp;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Models Group
$models_children_str = ""
foreach ($f in $swift_files_models) {
    $models_children_str += "`t`t`t`t$($file_refs[$f]) /* $f */,`n"
}
$objects += "`t`t$group_models_id /* Models */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n$models_children_str`t`t`t);`n`t`t`tpath = Models;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Views Group
$views_children_str = ""
foreach ($f in $swift_files_views) {
    $views_children_str += "`t`t`t`t$($file_refs[$f]) /* $f */,`n"
}
$views_children_str += "`t`t`t`t$group_components_id /* Components */,`n"
$objects += "`t`t$group_views_id /* Views */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n$views_children_str`t`t`t);`n`t`t`tpath = Views;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Components Group
$components_children_str = ""
foreach ($f in $swift_files_components) {
    $components_children_str += "`t`t`t`t$($file_refs[$f]) /* $f */,`n"
}
$objects += "`t`t$group_components_id /* Components */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n$components_children_str`t`t`t);`n`t`t`tpath = Components;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Resources Group
$objects += "`t`t$group_resources_id /* Resources */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n`t`t`t`t$plist_settings_id /* JarvisVoiceSettings.plist */,`n`t`t`t);`n`t`t`tpath = Resources;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Products Group
$objects += "`t`t$group_products_id /* Products */ = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n`t`t`t`t$app_product_id /* HeyJarvisApp.app */,`n`t`t`t);`n`t`t`tname = Products;`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# Main Group
$objects += "`t`t$group_main_id = {`n`t`t`tisa = PBXGroup;`n`t`t`tchildren = (`n`t`t`t`t$group_app_id /* HeyJarvisApp */,`n`t`t`t`t$group_products_id /* Products */,`n`t`t`t);`n`t`t`tsourceTree = `"<group>`";`n`t`t};"

# --- Phases ---
$phase_sources_id = "500000000000000000000001"
$phase_resources_id = "500000000000000000000002"
$phase_frameworks_id = "500000000000000000000003"

$sources_files_str = $source_build_refs -join ",`n`t`t`t`t"
$objects += "`t`t$phase_sources_id /* Sources */ = {`n`t`t`tisa = PBXSourcesBuildPhase;`n`t`t`tbuildActionMask = 2147483647;`n`t`t`tfiles = (`n`t`t`t`t$sources_files_str,`n`t`t`t);`n`t`t`trunOnlyForDeploymentPostprocessing = 0;`n`t`t};"

$objects += "`t`t$phase_resources_id /* Resources */ = {`n`t`t`tisa = PBXResourcesBuildPhase;`n`t`t`tbuildActionMask = 2147483647;`n`t`t`tfiles = (`n`t`t`t`t$assets_build_id /* Assets.xcassets in Resources */,`n`t`t`t`t$plist_settings_build_id /* JarvisVoiceSettings.plist in Resources */,`n`t`t`t);`n`t`t`trunOnlyForDeploymentPostprocessing = 0;`n`t`t};"

$objects += "`t`t$phase_frameworks_id /* Frameworks */ = {`n`t`t`tisa = PBXFrameworksBuildPhase;`n`t`t`tbuildActionMask = 2147483647;`n`t`t`tfiles = (`n`t`t`t);`n`t`t`trunOnlyForDeploymentPostprocessing = 0;`n`t`t};"

# --- Native Target ---
$target_id = "600000000000000000000001"
$config_list_target_id = "700000000000000000000001"

$objects += "`t`t$target_id /* HeyJarvisApp */ = {`n`t`t`tisa = PBXNativeTarget;`n`t`t`tbuildConfigurationList = $config_list_target_id /* Build configuration list for PBXNativeTarget `"HeyJarvisApp`" */;`n`t`t`tbuildPhases = (`n`t`t`t`t$phase_sources_id /* Sources */,`n`t`t`t`t$phase_frameworks_id /* Frameworks */,`n`t`t`t`t$phase_resources_id /* Resources */,`n`t`t`t);`n`t`t`tbuildRules = (`n`t`t`t);`n`t`t`tdependencies = (`n`t`t`t);`n`t`t`tname = HeyJarvisApp;`n`t`t`tproductName = HeyJarvisApp;`n`t`t`tproductReference = $app_product_id /* HeyJarvisApp.app */;`n`t`t`tproductType = `"com.apple.product-type.application`";`n`t`t};"

# --- Project ---
$project_id = "800000000000000000000001"
$config_list_project_id = "700000000000000000000002"

$objects += "`t`t$project_id /* Project object */ = {`n`t`t`tisa = PBXProject;`n`t`t`tattributes = {`n`t`t`t`tBuildIndependentTargetsInParallel = 1;`n`t`t`t`tLastUpgradeCheck = 1500;`n`t`t`t`tTargetAttributes = {`n`t`t`t`t`t$target_id = {`n`t`t`t`t`t`tCreatedOnToolsVersion = 15.0;`n`t`t`t`t`t};`n`t`t`t`t};`n`t`t`t};`n`t`t`tbuildConfigurationList = $config_list_project_id /* Build configuration list for PBXProject `"HeyJarvisApp`" */;`n`t`t`tcompatibilityVersion = `"Xcode 14.0`";`n`t`t`tdevelopmentRegion = en;`n`t`t`thasScannedForEncodings = 0;`n`t`t`tknownRegions = (`n`t`t`t`ten,`n`t`t`t`tBase,`n`t`t`t);`n`t`t`tmainGroup = $group_main_id;`n`t`t`tproductRefGroup = $group_products_id /* Products */;`n`t`t`tprojectDirPath = `"`";`n`t`t`tprojectRoot = `"`";`n`t`t`ttargets = (`n`t`t`t`t$target_id /* HeyJarvisApp */,`n`t`t`t);`n`t`t};"

# --- Build Configurations ---
$config_debug_id = "900000000000000000000001"
$config_release_id = "900000000000000000000002"
$config_target_debug_id = "900000000000000000000003"
$config_target_release_id = "900000000000000000000004"

$debug_config = @"
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
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
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"`$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
"@
$objects += "`t`t$config_debug_id /* Debug */ = {$debug_config};"

$release_config = @"
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
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
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
"@
$objects += "`t`t$config_release_id /* Release */ = {$release_config};"

$target_debug = @"
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "HeyJarvisApp/Preview Content";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = HeyJarvisApp/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"`$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.heyjarvis.app;
				PRODUCT_NAME = "`$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
"@
$objects += "`t`t$config_target_debug_id /* Debug */ = {$target_debug};"

$target_release = @"
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "HeyJarvisApp/Preview Content";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = HeyJarvisApp/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"`$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.heyjarvis.app;
				PRODUCT_NAME = "`$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
"@
$objects += "`t`t$config_target_release_id /* Release */ = {$target_release};"

$objects += "`t`t$config_list_project_id /* Build configuration list for PBXProject `"HeyJarvisApp`" */ = {`n`t`t`tisa = XCConfigurationList;`n`t`t`tbuildConfigurations = (`n`t`t`t`t$config_debug_id /* Debug */,`n`t`t`t`t$config_release_id /* Release */,`n`t`t`t);`n`t`t`tdefaultConfigurationIsVisible = 0;`n`t`t`tdefaultConfigurationName = Release;`n`t`t};"

$objects += "`t`t$config_list_target_id /* Build configuration list for PBXNativeTarget `"HeyJarvisApp`" */ = {`n`t`t`tisa = XCConfigurationList;`n`t`t`tbuildConfigurations = (`n`t`t`t`t$config_target_debug_id /* Debug */,`n`t`t`t`t$config_target_release_id /* Release */,`n`t`t`t);`n`t`t`tdefaultConfigurationIsVisible = 0;`n`t`t`tdefaultConfigurationName = Release;`n`t`t};"

# Combine everything
$content_lines = $objects -join "`n"

$content = "// !`$*UTF8*`$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
$content_lines
	};
	rootObject = $project_id /* Project object */;
}"

Set-Content -Path "HeyJarvisApp.xcodeproj/project.pbxproj" -Value $content -Encoding UTF8
Write-Host "Regenerated project.pbxproj successfully!"
