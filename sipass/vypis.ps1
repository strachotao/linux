#sipasscardexportJenVypsatStav; version 2019-06-13; strachotao

Param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [string]$userLogin
)

              
$sourceFile = "\\server\c$\Backup\CardHolder\CardHolder.csv"
$RunPath = Split-Path $MyInvocation.MyCommand.Path
$Log = "$RunPath\CardStatusLog.csv"


function Get-Timestamp() {
    return [System.DateTime]::Now.ToString("yyyy.MM.dd HH:mm:ss")    
}

if ( (Get-PSSnapin -Name quest.activeroles.admanagement -ErrorAction SilentlyContinue) -eq $Null ){
    Add-PsSnapin quest.activeroles.admanagement
}

if (Test-Path $sourceFile) {
    $data = Import-Csv $sourceFile
    Write-Host "timestamp;login;workgroupName;ADMember;SipassCardID;ADCardID;cardStatusBetweenSipassAndAD"
    foreach ($item in $data) {
        [string]$group = $item."workgroup name"
        $login = $item."last name"
        if (($login -eq $userLogin) -or ($userLogin -eq "")) {
            $cardID = "1$($item."card number")"
            if ($userData = Get-QADUser -SamAccountName $login -IncludedProperties otherpager) {
                $ADcardID = $($userData.otherpager)                                                
                if (($ADcardID -eq $null) -or ($ADcardID -eq "")){
                    Write-Host "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;ADCardID is empty" -ForegroundColor Magenta
                } elseif ($ADcardID.contains($cardID)) {
                    Write-Host "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;OK" -ForegroundColor Green                    
                } else {
                    Write-Host "$(Get-Timestamp);$login;$group;yes;$cardID;$ADcardID;CardID's are diffrent" -ForegroundColor Red
                }

            } else {
                Write-Host "$(Get-Timestamp);$login;$group;no;$cardID;;User is not in AD" -ForegroundColor Cyan
            }
        }
    }
} else {
    Write-Host "source file $sourceFile doesn't exists"
}
