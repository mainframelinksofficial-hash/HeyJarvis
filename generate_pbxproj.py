import uuid

def generate_id(prefix, index):
    return f"{prefix}{index:04X}"

# Files Configuration
swift_files_root = [
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
]

swift_files_models = ["Command.swift", "TTSError.swift"]
swift_files_views = [
    "CommandHistoryView.swift", "CommandReferenceView.swift", 
    "ConversationHistoryView.swift", "JarvisMindView.swift", 
    "SettingsView.swift", "StatusView.swift"
]
swift_files_components = [
    "GlassesStatusView.swift", "HeaderView.swift", 
    "JarvisResponseView.swift", "TranscriptionView.swift"
]

resources = ["Assets.xcassets", "JarvisVoiceSettings.plist"]
info_plist = "Info.plist"

# ID Generators
# 10xx: File Refs
# 20xx: Build Files (Sources)
# 30xx: Build Files (Resources)
# 40xx: Groups

objects = []

# --- PBXFileReference ---
file_refs = {}

# Root Swift Files
for i, f in enumerate(swift_files_root):
    fid = generate_id("10000000000000000000", i)
    file_refs[f] = fid
    objects.append(f'\t\t{fid} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')

# Models
for i, f in enumerate(swift_files_models):
    fid = generate_id("10000000000000000001", i)
    file_refs[f] = fid
    objects.append(f'\t\t{fid} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')

# Views
for i, f in enumerate(swift_files_views):
    fid = generate_id("10000000000000000002", i)
    file_refs[f] = fid
    objects.append(f'\t\t{fid} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')

# Components
for i, f in enumerate(swift_files_components):
    fid = generate_id("10000000000000000003", i)
    file_refs[f] = fid
    objects.append(f'\t\t{fid} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')

# Resources
assets_id = "100000000000000000040000"
plist_settings_id = "100000000000000000040001"
objects.append(f'\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
objects.append(f'\t\t{plist_settings_id} /* JarvisVoiceSettings.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = JarvisVoiceSettings.plist; sourceTree = "<group>"; }};')

# Info.plist
info_plist_id = "100000000000000000050000"
objects.append(f'\t\t{info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')

# App Product
app_product_id = "200000000000000000000000"
objects.append(f'\t\t{app_product_id} /* HeyJarvisApp.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HeyJarvisApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};')


# --- PBXBuildFile (Sources) ---
source_build_files = []
for f, fid in file_refs.items():
    bid = fid.replace("1000", "2000")
    source_build_files.append(bid)
    objects.append(f'\t\t{bid} /* {f} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {f} */; }};')

# --- PBXBuildFile (Resources) ---
assets_build_id = assets_id.replace("1000", "3000")
plist_settings_build_id = plist_settings_id.replace("1000", "3000")
objects.append(f'\t\t{assets_build_id} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};')
objects.append(f'\t\t{plist_settings_build_id} /* JarvisVoiceSettings.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {plist_settings_id} /* JarvisVoiceSettings.plist */; }};')


# --- PBXGroup ---
group_app_id = "400000000000000000000001"
group_models_id = "400000000000000000000002"
group_views_id = "400000000000000000000003"
group_components_id = "400000000000000000000004"
group_resources_id = "400000000000000000000005"
group_main_id = "400000000000000000000000"
group_products_id = "400000000000000000000006"

# Root Group Children
root_children = [file_refs[f] for f in swift_files_root]
root_children.extend([group_models_id, group_views_id, group_resources_id, assets_id, info_plist_id])

objects.append(f"""\t\t{group_app_id} /* HeyJarvisApp */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{', '.join([f'{cid} /* {cname} */' for cid, cname in zip(
                    [file_refs[f] for f in swift_files_root], 
                    swift_files_root
                )])},
\t\t\t\t{group_models_id} /* Models */,
\t\t\t\t{group_views_id} /* Views */,
\t\t\t\t{group_resources_id} /* Resources */,
\t\t\t\t{assets_id} /* Assets.xcassets */,
\t\t\t\t{info_plist_id} /* Info.plist */,
\t\t\t);
\t\t\tpath = HeyJarvisApp;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_models_id} /* Models */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{', '.join([f'{file_refs[f]} /* {f} */' for f in swift_files_models])},
\t\t\t);
\t\t\tpath = Models;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_views_id} /* Views */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{', '.join([f'{file_refs[f]} /* {f} */' for f in swift_files_views])},
\t\t\t\t{group_components_id} /* Components */,
\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_components_id} /* Components */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{', '.join([f'{file_refs[f]} /* {f} */' for f in swift_files_components])},
\t\t\t);
\t\t\tpath = Components;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_resources_id} /* Resources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{plist_settings_id} /* JarvisVoiceSettings.plist */,
\t\t\t);
\t\t\tpath = Resources;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_products_id} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_id} /* HeyJarvisApp.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};""")

objects.append(f"""\t\t{group_main_id} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{group_app_id} /* HeyJarvisApp */,
\t\t\t\t{group_products_id} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};""")

# --- Phases ---
phase_sources_id = "500000000000000000000001"
phase_resources_id = "500000000000000000000002"
phase_frameworks_id = "500000000000000000000003"

objects.append(f"""\t\t{phase_sources_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{', '.join([f'{bid} /* {f} in Sources */' for bid, f in zip(source_build_files, list(file_refs.keys()))])},
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};""")

objects.append(f"""\t\t{phase_resources_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{assets_build_id} /* Assets.xcassets in Resources */,
\t\t\t\t{plist_settings_build_id} /* JarvisVoiceSettings.plist in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};""")

objects.append(f"""\t\t{phase_frameworks_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};""")

# --- Native Target ---
target_id = "600000000000000000000001"
config_list_target_id = "700000000000000000000001"
objects.append(f"""\t\t{target_id} /* HeyJarvisApp */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {config_list_target_id} /* Build configuration list for PBXNativeTarget "HeyJarvisApp" */;
\t\t\tbuildPhases = (
\t\t\t\t{phase_sources_id} /* Sources */,
\t\t\t\t{phase_frameworks_id} /* Frameworks */,
\t\t\t\t{phase_resources_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = HeyJarvisApp;
\t\t\tproductName = HeyJarvisApp;
\t\t\tproductReference = {app_product_id} /* HeyJarvisApp.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};""")

# --- Project ---
project_id = "800000000000000000000001"
config_list_project_id = "700000000000000000000002"

objects.append(f"""\t\t{project_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_id} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {config_list_project_id} /* Build configuration list for PBXProject "HeyJarvisApp" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {group_main_id};
\t\t\tproductRefGroup = {group_products_id} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_id} /* HeyJarvisApp */,
\t\t\t);
\t\t}};""")

# --- Build Configurations ---
config_debug_id = "900000000000000000000001"
config_release_id = "900000000000000000000002"
config_target_debug_id = "900000000000000000000003"
config_target_release_id = "900000000000000000000004"

objects.append(f"""\t\t{config_debug_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};""")

objects.append(f"""\t\t{config_release_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};""")

objects.append(f"""\t\t{config_target_debug_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "HeyJarvisApp/Preview Content";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = HeyJarvisApp/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.heyjarvis.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};""")

objects.append(f"""\t\t{config_target_release_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "HeyJarvisApp/Preview Content";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = HeyJarvisApp/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.heyjarvis.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};""")

objects.append(f"""\t\t{config_list_project_id} /* Build configuration list for PBXProject "HeyJarvisApp" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{config_debug_id} /* Debug */,
\t\t\t\t{config_release_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};""")

objects.append(f"""\t\t{config_list_target_id} /* Build configuration list for PBXNativeTarget "HeyJarvisApp" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{config_target_debug_id} /* Debug */,
\t\t\t\t{config_target_release_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};""")

# Write File
content = "// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {\n\t};\n\tobjectVersion = 56;\n\tobjects = {\n"
content += "\n".join(objects)
content += "\n\t};\n\trootObject = " + project_id + " /* Project object */;\n}"

with open("HeyJarvisApp.xcodeproj/project.pbxproj", "w") as f:
    f.write(content)

print("Regenerated project.pbxproj successfully!")
