# Create base directories for each exam group
$baseDir = "JavaApp/src/main/resources/mcqs"

# UPSC Exams
New-Item -Path "$baseDir/upsc/civil_services/ias" -ItemType Directory -Force
New-Item -Path "$baseDir/upsc/engineering_services/ies" -ItemType Directory -Force
New-Item -Path "$baseDir/upsc/engineering_services/ifs" -ItemType Directory -Force
New-Item -Path "$baseDir/upsc/defence_services/cds" -ItemType Directory -Force
New-Item -Path "$baseDir/upsc/defence_services/nda" -ItemType Directory -Force
New-Item -Path "$baseDir/upsc/defence_services/capf" -ItemType Directory -Force

# SSC Exams
New-Item -Path "$baseDir/ssc/graduate_level/cgl" -ItemType Directory -Force
New-Item -Path "$baseDir/ssc/higher_secondary/chsl" -ItemType Directory -Force
New-Item -Path "$baseDir/ssc/higher_secondary/stenographer" -ItemType Directory -Force

# Banking Exams
New-Item -Path "$baseDir/banking/banking_exams/ibps_po" -ItemType Directory -Force
New-Item -Path "$baseDir/banking/banking_exams/ibps_clerk" -ItemType Directory -Force
New-Item -Path "$baseDir/banking/banking_exams/sbi_po" -ItemType Directory -Force
New-Item -Path "$baseDir/banking/insurance_exams/lic_aao" -ItemType Directory -Force
New-Item -Path "$baseDir/banking/insurance_exams/nabard" -ItemType Directory -Force

# Railway Exams
New-Item -Path "$baseDir/railway/non_technical_posts/rrb_ntpc" -ItemType Directory -Force
New-Item -Path "$baseDir/railway/non_technical_posts/rrb_group_d" -ItemType Directory -Force
New-Item -Path "$baseDir/railway/technical_safety_posts/rrb_je" -ItemType Directory -Force
New-Item -Path "$baseDir/railway/technical_safety_posts/rrb_alp" -ItemType Directory -Force
New-Item -Path "$baseDir/railway/technical_safety_posts/rrb_paramedical" -ItemType Directory -Force

# State PSC Exams
New-Item -Path "$baseDir/state_psc/administrative_services/state_civil_services" -ItemType Directory -Force
New-Item -Path "$baseDir/state_psc/state_police_services/state_police_exams" -ItemType Directory -Force
New-Item -Path "$baseDir/state_psc/state_engineering_services/state_psc_engineering" -ItemType Directory -Force
New-Item -Path "$baseDir/state_psc/misc_state_exams/state_revenue_officer" -ItemType Directory -Force

# Defence & Paramilitary Exams
New-Item -Path "$baseDir/defence_paramilitary/indian_armed_forces/afcat" -ItemType Directory -Force
New-Item -Path "$baseDir/defence_paramilitary/indian_armed_forces/nda_na" -ItemType Directory -Force
New-Item -Path "$baseDir/defence_paramilitary/indian_armed_forces/cds" -ItemType Directory -Force
New-Item -Path "$baseDir/defence_paramilitary/paramilitary_police_forces/capf_ac" -ItemType Directory -Force
New-Item -Path "$baseDir/defence_paramilitary/paramilitary_police_forces/icg" -ItemType Directory -Force
New-Item -Path "$baseDir/defence_paramilitary/paramilitary_police_forces/ssc_cpo" -ItemType Directory -Force

# Teaching & Education Exams
New-Item -Path "$baseDir/teaching_education/school_level_teaching/ctet" -ItemType Directory -Force
New-Item -Path "$baseDir/teaching_education/school_level_teaching/state_tet" -ItemType Directory -Force
New-Item -Path "$baseDir/teaching_education/school_level_teaching/kvs_nvs" -ItemType Directory -Force
New-Item -Path "$baseDir/teaching_education/school_level_teaching/dsssb" -ItemType Directory -Force
New-Item -Path "$baseDir/teaching_education/college_university_level/ugc_net" -ItemType Directory -Force

# Judicial Services Exams
New-Item -Path "$baseDir/judicial_services/lower_judiciary/pcs_j" -ItemType Directory -Force
New-Item -Path "$baseDir/judicial_services/higher_judiciary/district_judge" -ItemType Directory -Force

# PSU Exams
New-Item -Path "$baseDir/psu_exams/engineering_psu/gate_psu" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/engineering_psu/energy_psu" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/non_engineering_psu/fssai" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/non_engineering_psu/scientific_orgs" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/non_engineering_psu/epfo" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/non_engineering_psu/ib_exams" -ItemType Directory -Force
New-Item -Path "$baseDir/psu_exams/non_engineering_psu/esic" -ItemType Directory -Force

Write-Host "Created all exam subject folders successfully!" 