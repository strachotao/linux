<#
cardStatus; version 2019-06-13; strachotao
#>

              
$sourceFile = "\\server\c$\Backup\CardHolder\CardHolder.csv"
$RunPath = Split-Path $MyInvocation.MyCommand.Path
$Log = "\\domena.cz\data\axashares\_Public\IT\emp_pic\cardStatusLog.csv"

if ( (Get-PSSnapin -Name quest.activeroles.admanagement -ErrorAction SilentlyContinue) -eq $Null ){
    Add-PsSnapin quest.activeroles.admanagement
}

function Get-Timestamp() {
    return [System.DateTime]::Now.ToString("yyyy.MM.dd HH:mm:ss")    
}


if (Test-Path $sourceFile) {
    $data = Import-Csv $sourceFile
    Clear-Content $Log
    Add-Content $Log "timestamp;login;workgroupName;ADMember;SipassCardID;ADCardID;cardStatusBetweenSipassAndAD"
    foreach ($item in $data) {
        [string]$group = $item."workgroup name"
        $login = $item."last name"
        if (($login -eq $userLogin) -or ($userLogin -eq "")) {
            $cardID = "1$($item."card number")"
            if ($userData = Get-QADUser -SamAccountName $login -IncludedProperties otherpager) {
                $ADcardID = $($userData.otherpager)                                                
                if (($ADcardID -eq $null) -or ($ADcardID -eq "")) {
                    Add-Content $Log "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;ADCardID is empty" -ForegroundColor Magenta
                } elseif ($ADcardID.contains($cardID)) {
                    Add-Content $Log "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;OK" -ForegroundColor Green                    
                } else {
                    Add-Content $Log "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;CardID's are diffrent" -ForegroundColor Red
                }

            } else {
                Add-Content $Log "$(Get-Timestamp);$login;$group;no;$cardID;;User is not in AD" -ForegroundColor Cyan
            }
        }
    }
} else {
    Add-Content $Log "source file $sourceFile doesn't exists"
}
