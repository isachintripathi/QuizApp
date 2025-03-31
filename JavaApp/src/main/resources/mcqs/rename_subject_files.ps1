# Base directory for MCQs
$baseDir = "JavaApp/src/main/resources/mcqs"

# Function to rename subject files
function Rename-SubjectFiles {
    param (
        [string]$groupDir,
        [string]$subgroupDir,
        [string]$examDir
    )
    
    $examPath = "$baseDir/$groupDir/$subgroupDir/$examDir"
    $examPath = $examPath.Replace("\", "/")
    
    if (Test-Path $examPath) {
        $examName = Split-Path $examDir -Leaf
        Get-ChildItem -Path $examPath -Filter "*.json" | ForEach-Object {
            if (-not $_.Name.StartsWith($examName)) {
                $newName = "$examName`_$($_.Name)"
                Rename-Item -Path $_.FullName -NewName $newName -Force
                Write-Host "Renamed $($_.Name) to $newName in $examPath"
            }
        }
    } else {
        Write-Host "Path not found: $examPath"
    }
}

# Read data.json to get the structure
$dataJson = Get-Content "JavaApp/src/main/resources/data.json" | ConvertFrom-Json

# Process each group, subgroup, and exam
foreach ($group in $dataJson.groups) {
    foreach ($subgroup in $group.subgroups) {
        foreach ($exam in $subgroup.exams) {
            Write-Host "Processing $($group.id)/$($subgroup.id)/$($exam.id)"
            Rename-SubjectFiles -groupDir $group.id -subgroupDir $subgroup.id -examDir $exam.id
        }
    }
}

Write-Host "Completed renaming subject files!" 