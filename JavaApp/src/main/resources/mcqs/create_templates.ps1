# Base directory for MCQs
$baseDir = "JavaApp/src/main/resources/mcqs"

# Function to create template JSON for a subject
function Create-SubjectTemplate {
    param (
        [string]$examPath,
        [string]$subject
    )
    
    $template = @"
{
    "subject": "$subject",
    "questions": [
        {
            "id": "1",
            "question": "Sample question for $subject?",
            "options": [
                "Option A",
                "Option B",
                "Option C",
                "Option D"
            ],
            "correctAnswer": 0,
            "explanation": "Explanation for the correct answer"
        }
    ]
}
"@
    
    $template | Out-File -FilePath "$examPath/$subject.json" -Encoding UTF8
}

# Create templates for each exam based on their subjects from data.json
$dataJson = Get-Content "JavaApp/src/main/resources/data.json" | ConvertFrom-Json

foreach ($group in $dataJson.groups) {
    foreach ($subgroup in $group.subgroups) {
        foreach ($exam in $subgroup.exams) {
            $examPath = "$baseDir/$($group.id)/$($subgroup.id)/$($exam.id)"
            foreach ($subject in $exam.subjects) {
                Create-SubjectTemplate -examPath $examPath -subject $subject
            }
        }
    }
}

Write-Host "Created all subject template files successfully!" 