#!/usr/bin/env python3
"""Generate the dependency-free native Xcode target from the canonical Swift sources."""
from pathlib import Path
import hashlib
import plistlib

ROOT = Path(__file__).resolve().parent.parent
objects = {}


def identifier(name):
    return hashlib.sha256(name.encode()).hexdigest()[:24].upper()


def add(object_name, isa, **fields):
    key = identifier(object_name)
    objects[key] = {"isa": isa, **fields}
    return key


source_files = sorted((ROOT / "Sources/BendCore").glob("*.swift")) + sorted((ROOT / "Sources/BendMe").glob("*.swift"))
source_refs = []
source_builds = []
for path in source_files:
    relative = str(path.relative_to(ROOT))
    ref = add(relative, "PBXFileReference", lastKnownFileType="sourcecode.swift", path=relative, sourceTree="SOURCE_ROOT")
    source_refs.append(ref)
    source_builds.append(add("build " + relative, "PBXBuildFile", fileRef=ref))

resource_refs = []
resource_builds = []
for path, filetype in [("distribution/Assets.xcassets", "folder.assetcatalog"), ("distribution/PrivacyInfo.xcprivacy", "text.xml")]:
    ref = add(path, "PBXFileReference", lastKnownFileType=filetype, path=path, sourceTree="SOURCE_ROOT")
    resource_refs.append(ref)
    resource_builds.append(add("build " + path, "PBXBuildFile", fileRef=ref))

product = add("product", "PBXFileReference", explicitFileType="wrapper.application", includeInIndex="0", path="BendMe.app", sourceTree="BUILT_PRODUCTS_DIR")
products = add("products", "PBXGroup", children=[product], name="Products", sourceTree="<group>")
sources = add("sources", "PBXGroup", children=source_refs, name="Sources", sourceTree="<group>")
resources = add("resources", "PBXGroup", children=resource_refs, name="Resources", sourceTree="<group>")
main = add("main", "PBXGroup", children=[sources, resources, products], sourceTree="<group>")
phase_sources = add("phase sources", "PBXSourcesBuildPhase", buildActionMask="2147483647", files=source_builds, runOnlyForDeploymentPostprocessing="0")
phase_resources = add("phase resources", "PBXResourcesBuildPhase", buildActionMask="2147483647", files=resource_builds, runOnlyForDeploymentPostprocessing="0")
phase_frameworks = add("phase frameworks", "PBXFrameworksBuildPhase", buildActionMask="2147483647", files=[], runOnlyForDeploymentPostprocessing="0")
phase_shader = add("phase shader", "PBXShellScriptBuildPhase", buildActionMask="2147483647", files=[], name="Bundle Metal shader", inputPaths=["$(SRCROOT)/Sources/BendMe/Resources/Fold.metal"], outputPaths=["$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/BendMe_BendMe.bundle/Resources/Fold.metal"], runOnlyForDeploymentPostprocessing="0", shellPath="/bin/sh", shellScript='set -eu\ndestination="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/BendMe_BendMe.bundle/Resources"\nmkdir -p "$destination"\ncp "${SRCROOT}/Sources/BendMe/Resources/Fold.metal" "$destination/Fold.metal"\n')

project_configs = []
target_configs = []
for name in ["Debug", "Release"]:
    project_configs.append(add("project " + name, "XCBuildConfiguration", name=name, buildSettings={"CLANG_ENABLE_MODULES": "YES", "MACOSX_DEPLOYMENT_TARGET": "14.0", "SDKROOT": "macosx", "SWIFT_VERSION": "5.0", "SWIFT_OPTIMIZATION_LEVEL": "-Onone" if name == "Debug" else "-O", "DEBUG_INFORMATION_FORMAT": "dwarf" if name == "Debug" else "dwarf-with-dsym", "ONLY_ACTIVE_ARCH": "YES" if name == "Debug" else "NO"}))
    target_configs.append(add("target " + name, "XCBuildConfiguration", name=name, buildSettings={"ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon", "CODE_SIGN_ENTITLEMENTS": "distribution/AppStore.entitlements", "CODE_SIGN_STYLE": "Automatic", "CURRENT_PROJECT_VERSION": "4", "ENABLE_APP_SANDBOX": "YES", "ENABLE_HARDENED_RUNTIME": "YES", "ENABLE_USER_SCRIPT_SANDBOXING": "YES", "GENERATE_INFOPLIST_FILE": "NO", "INFOPLIST_FILE": "distribution/Info.plist", "MARKETING_VERSION": "0.1.3", "PRODUCT_BUNDLE_IDENTIFIER": "com.winsonbaring.bendme", "PRODUCT_NAME": "$(TARGET_NAME)", "SUPPORTED_PLATFORMS": "macosx", "ARCHS": "arm64", "COMBINE_HIDPI_IMAGES": "YES", "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/../Frameworks"], "SWIFT_EMIT_LOC_STRINGS": "YES", "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG" if name == "Debug" else ""}))

pc = add("project configs", "XCConfigurationList", buildConfigurations=project_configs, defaultConfigurationIsVisible="0", defaultConfigurationName="Release")
tc = add("target configs", "XCConfigurationList", buildConfigurations=target_configs, defaultConfigurationIsVisible="0", defaultConfigurationName="Release")
target = add("target", "PBXNativeTarget", buildConfigurationList=tc, buildPhases=[phase_sources, phase_frameworks, phase_resources, phase_shader], buildRules=[], dependencies=[], name="BendMe", productName="BendMe", productReference=product, productType="com.apple.product-type.application")
project = add("project", "PBXProject", attributes={"BuildIndependentTargetsInParallel": "YES", "LastUpgradeCheck": "2600"}, buildConfigurationList=pc, compatibilityVersion="Xcode 14.0", developmentRegion="en", hasScannedForEncodings="0", knownRegions=["en", "Base"], mainGroup=main, productRefGroup=products, projectDirPath="", projectRoot="", targets=[target])
destination = ROOT / "BendMe.xcodeproj"
destination.mkdir(exist_ok=True)
(destination / "project.pbxproj").write_bytes(plistlib.dumps({"archiveVersion": "1", "classes": {}, "objectVersion": "56", "objects": objects, "rootObject": project}, sort_keys=False))
scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2600" version="1.3">
 <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="BendMe.app" BlueprintName="BendMe" ReferencedContainer="container:BendMe.xcodeproj"/></BuildActionEntry></BuildActionEntries></BuildAction>
 <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="NO"><BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="BendMe.app" BlueprintName="BendMe" ReferencedContainer="container:BendMe.xcodeproj"/></BuildableProductRunnable></LaunchAction>
 <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
'''
scheme_directory = destination / "xcshareddata/xcschemes"
scheme_directory.mkdir(parents=True, exist_ok=True)
(scheme_directory / "BendMe.xcscheme").write_text(scheme)
print("Generated BendMe.xcodeproj from canonical Swift sources.")
