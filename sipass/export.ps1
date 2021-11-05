# 	version 2018-06-13; strachotao
              
$source = "\\server\c$\Backup\CardHolder\CardHolder.csv"
$RunPath = Split-Path $MyInvocation.MyCommand.Path
$Log = "$RunPath\sipasscardexportLOG.csv"

if ( (Get-PSSnapin -Name quest.activeroles.admanagement -ErrorAction SilentlyContinue) -eq $Null ){
    Add-PsSnapin quest.activeroles.admanagement
}

Function Get-Timestamp {
    return [System.DateTime]::Now.ToString("yyyy.MM.dd HH:mm:ss")    
}

[string]$attribute = "otherPager"

if (Test-Path $source) {
    $data = Import-Csv $source    
    foreach ($item in $data) {
        [string]$group = $item."workgroup name"
        [string]$login = $item."last name"
        [string]$cardID = "1$($item."card number")"
        if ($userData = Get-QADUser -SamAccountName $login -IncludedProperties otherpager) {
            $ADcardID = $($userData.otherpager)                
            if (($ADcardID -eq $null) -or ($ADcardID -eq "")) {
                $add = "$cardID"
                Set-QADUser -Identity $login -ObjectAttributes @{($attribute)=$($add)} | Out-Null
                $newValue = Get-QADUser -SamAccountName $login -IncludedProperties otherpager
                Add-Content $Log "$(Get-Timestamp);$login;yes;$cardID;$ADcardID;null;$($newValue.otherpager)"
            } elseif ($ADcardID.contains($cardID)) {
                Add-Content $Log "$(Get-Timestamp);$login;yes;$cardID;$ADcardID;OK;;"
            } else {
                $add = "$ADcardID,$cardID"
                Set-QADUser -Identity $login -ObjectAttributes @{($attribute)=$($add)} | Out-Null
                $newValue = Get-QADUser -SamAccountName $login -IncludedProperties otherpager
                Add-Content $Log "$(Get-Timestamp);$login;yes;$cardID;$ADcardID;diff;$($newValue.otherpager)"
            }
        } else {
            Add-Content $Log "$(Get-Timestamp);$login;no;$cardID;;noAD;"
        }
    }
}
