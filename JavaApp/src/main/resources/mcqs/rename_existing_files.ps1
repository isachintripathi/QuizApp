# Base directory for MCQs
$baseDir = "JavaApp/src/main/resources/mcqs"

# Function to rename files in a directory
function Rename-FilesInDirectory {
    param (
        [string]$dirPath
    )
    
    if (Test-Path $dirPath) {
        $examName = Split-Path $dirPath -Leaf
        Get-ChildItem -Path $dirPath -Filter "*.json" | ForEach-Object {
            if (-not $_.Name.Contains("_")) {
                $newName = "$examName`_$($_.Name)"
                $newPath = Join-Path $dirPath $newName
                Rename-Item -Path $_.FullName -NewName $newName -Force
                Write-Host "Renamed $($_.Name) to $newName"
            }
        }
    }
}

# Get all exam directories
Get-ChildItem -Path $baseDir -Recurse -Directory | ForEach-Object {
    Rename-FilesInDirectory -dirPath $_.FullName
}

Write-Host "Completed renaming existing files!" 