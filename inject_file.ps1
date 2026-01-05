
$path = "HeyJarvisApp.xcodeproj/project.pbxproj"
$lines = Get-Content $path
$newLines = @()

$fileRefId = "FFFFFFFF00000001"
$buildFileId = "FFFFFFFF00000002"
$fileName = "OpenAITTSManager.swift"

$addedFileRef = $false
$addedBuildFile = $false
$addedToGroup = $false
$addedToSources = $false

foreach ($line in $lines) {
    # 1. Add PBXBuildFile
    if (-not $addedBuildFile -and $line -match "/* Begin PBXBuildFile section */") {
        $newLines += $line
        $newLines += "`t`t$buildFileId /* $fileName in Sources */ = {isa = PBXBuildFile; fileRef = $fileRefId /* $fileName */; };"
        $addedBuildFile = $true
        continue
    }

    # 2. Add PBXFileReference
    if (-not $addedFileRef -and $line -match "/* Begin PBXFileReference section */") {
        $newLines += $line
        $newLines += "`t`t$fileRefId /* $fileName */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $fileName; sourceTree = `"<group>`"; };"
        $addedFileRef = $true
        continue
    }

    # 3. Add to Group (HeyJarvisApp)
    # Finding the main group children. Usually identified by path = HeyJarvisApp; and isa = PBXGroup;
    # But simpler to just add it after HeyJarvisApp.swift which we know is in the main group
    if (-not $addedToGroup -and $line -match "HeyJarvisApp.swift \*/,") {
        # careful not to add it inside PBXBuildFile section which also has this string
        # check previous lines? No, simplistic check: 
        # The group section lines usually start with 4 tabs, build files start with 2.
        if ($line.Trim().StartsWith("B1C2D3E4F5A60001 /* HeyJarvisApp.swift */,")) { 
            $newLines += $line
            $newLines += "`t`t`t`t$fileRefId /* $fileName */,"
            $addedToGroup = $true
            continue
        }
    }
    
    # 4. Add to Sources Phase
    # Finding PBXSourcesBuildPhase
    if (-not $addedToSources -and $line -match "isa = PBXSourcesBuildPhase;") {
        # We need to find the 'files = (' line after this
        $newLines += $line
        continue
    }
    if (-not $addedToSources -and $line -match "files = \(") {
        # Add after opening brace IF we recently saw PBXSourcesBuildPhase
        # But global flag is easier. We assume standard order.
        # Let's just look for a known source build file to append after.
        # "HeyJarvisApp.swift in Sources"
    }
    
    if (-not $addedToSources -and $line -match "HeyJarvisApp.swift in Sources \*/,") {
        $newLines += $line
        $newLines += "`t`t`t`t$buildFileId /* $fileName in Sources */,"
        $addedToSources = $true
        continue
    }

    $newLines += $line
}

# Fallback for Group if simplistic match failed (it depends on ID). 
# The ID for HeyJarvisApp.swift is B1C2D3E4F5A60001 based on previous `view_file_outline`.
# Let's verify the group insertion happened. If not, we might have issues.

$newLines | Set-Content $path -Encoding UTF8
Write-Host "Injected OpenAITTSManager.swift"
