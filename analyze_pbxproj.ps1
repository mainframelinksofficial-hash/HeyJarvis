
# Analysis Script
$path = "HeyJarvisApp.xcodeproj/project.pbxproj"
$content = Get-Content $path
$files = @{}

# Regex to capture file references in PBXFileReference section
# Format: 		B1C2D3E4F5A60016 /* TTSError.swift */ = {isa = PBXFileReference; ... path = TTSError.swift; ... };
$regex = "([A-F0-9]+) /\* (.+) \*/ = \{isa = PBXFileReference;"

foreach ($line in $content) {
    if ($line -match $regex) {
        $id = $matches[1]
        $name = $matches[2]
        if ($files.ContainsKey($name)) {
            $files[$name] += 1
        }
        else {
            $files[$name] = 1
        }
    }
}

$duplicates = $files.GetEnumerator() | Where-Object { $_.Value -gt 1 }
Write-Host "Duplicate File References found:"
$duplicates | Format-Table -AutoSize

# Check Swift files that are NOT in the project
$actualFiles = Get-ChildItem -Path "HeyJarvisApp" -Recurse -Filter "*.swift" | Select-Object -ExpandProperty Name
$missing = @()
foreach ($f in $actualFiles) {
    if (-not $files.ContainsKey($f)) {
        $missing += $f
    }
}

Write-Host "`nMissing Swift Files from Project:"
$missing
