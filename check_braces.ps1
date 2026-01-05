
$swiftFiles = Get-ChildItem -Path "c:\Users\jacob\Downloads\Meta\HeyJarvisApp" -Recurse -Filter "*.swift"

foreach ($file in $swiftFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($null -ne $content) {
        $openCount = ($content | Select-String -Pattern "{" -AllMatches).Matches.Count
        $closeCount = ($content | Select-String -Pattern "}" -AllMatches).Matches.Count
        
        if ($openCount -ne $closeCount) {
            Write-Host "MISMATCH: $($file.Name)" -ForegroundColor Red
            Write-Host "  Open:  $openCount"
            Write-Host "  Close: $closeCount"
            Write-Host "  Diff:  $($openCount - $closeCount)"
        }
        else {
            # Write-Host "OK: $($file.Name)" -ForegroundColor Green
        }
    }
}
Write-Host "Done checking braces."
