
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
    if (-not $addedBuildFile -and $line.Contains("/* Begin PBXBuildFile section */")) {
        $newLines += $line
        $newLines += "`t`t$buildFileId /* $fileName in Sources */ = {isa = PBXBuildFile; fileRef = $fileRefId /* $fileName */; };"
        $addedBuildFile = $true
        continue
    }

    # 2. Add PBXFileReference
    if (-not $addedFileRef -and $line.Contains("/* Begin PBXFileReference section */")) {
        $newLines += $line
        $newLines += "`t`t$fileRefId /* $fileName */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = $fileName; sourceTree = `"<group>`"; };"
        $addedFileRef = $true
        continue
    }

    # 3. Add to Group (HeyJarvisApp)
    # We look for HeyJarvisApp.swift reference inside the group structure
    # The line usually looks like: B1C2D3E4F5A60001 /* HeyJarvisApp.swift */,
    # But we must be careful not to match the PBXFileReference line which ends with };
    if (-not $addedToGroup -and $line.Contains("/* HeyJarvisApp.swift */,") -and -not $line.Contains("};")) {
        $newLines += $line
        $newLines += "`t`t`t`t$fileRefId /* $fileName */,"
        $addedToGroup = $true
        continue
    }
    
    # 4. Add to Sources Phase
    # We look for HeyJarvisApp.swift reference inside the sources build phase
    # Line: B1C2D3E4F5A60001 /* HeyJarvisApp.swift in Sources */,
    if (-not $addedToSources -and $line.Contains("/* HeyJarvisApp.swift in Sources */,")) {
        $newLines += $line
        $newLines += "`t`t`t`t$buildFileId /* $fileName in Sources */,"
        $addedToSources = $true
        continue
    }

    $newLines += $line
}

$newLines | Set-Content $path -Encoding UTF8
Write-Host "Injected into:"
if ($addedBuildFile) { Write-Host "- PBXBuildFile" }
if ($addedFileRef) { Write-Host "- PBXFileReference" }
if ($addedToGroup) { Write-Host "- Group" }
if ($addedToSources) { Write-Host "- Sources Phase" }
