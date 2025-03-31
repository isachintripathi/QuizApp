# Base directory for MCQs
$baseDir = "."

# Function to create a set file
function Create-SetFile {
    param (
        [string]$groupDir,
        [string]$subgroupDir,
        [string]$examDir,
        [string]$examId,
        [string]$setType
    )
    
    $examPath = "$baseDir/$groupDir/$subgroupDir/$examDir"
    $examPath = $examPath.Replace("\", "/")
    
    if (Test-Path $examPath) {
        $setFileName = "$examId`_$setType`_set.json"
        $setFilePath = Join-Path $examPath $setFileName
        
        # Create a sample set JSON structure
        $setContent = @{
            "set_id" = "1"
            "exam_id" = $examId
            "set_type" = $setType
            "total_questions" = 10
            "time_limit_minutes" = 15
            "difficulty_level" = $setType
            "questions" = @(
                @{
                    "id" = "1"
                    "question" = "Sample question 1"
                    "options" = @("Option A", "Option B", "Option C", "Option D")
                    "correct_answer" = 0
                    "explanation" = "Explanation for the correct answer"
                    "difficulty_level" = $setType
                }
            )
        }
        
        # Convert to JSON and save
        $jsonContent = $setContent | ConvertTo-Json -Depth 10
        $jsonContent | Set-Content -Path $setFilePath -Force
        Write-Host "Created set file: $setFileName in $examPath"
    } else {
        Write-Host "Path not found: $examPath"
    }
}

# Read data.json to get the structure
$dataJson = Get-Content "../data.json" | ConvertFrom-Json

# Define set types
$setTypes = @("easy", "medium", "hard", "quick_test")

# Process each group, subgroup, and exam
foreach ($group in $dataJson.groups) {
    foreach ($subgroup in $group.subgroups) {
        foreach ($exam in $subgroup.exams) {
            Write-Host "Processing $($group.id)/$($subgroup.id)/$($exam.id)"
            
            # Create a set file for each set type
            foreach ($setType in $setTypes) {
                Create-SetFile -groupDir $group.id -subgroupDir $subgroup.id -examDir $exam.id -examId $exam.id -setType $setType
            }
        }
    }
}

Write-Host "Completed creating set files!" 