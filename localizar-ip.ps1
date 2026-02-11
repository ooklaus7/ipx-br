param(
    [Parameter(Position = 0)]
    [string]$Ip,
    [switch]$Help,
    [switch]$Json,
    [string]$Out,
    [string]$Batch,
    [switch]$NoColor,
    [switch]$MeuIp,
    [switch]$MeuIpPrivado,
    [switch]$Map
)

$NomeFerramenta = "ipx br"
$Versao = "2.0.0"
$Autor = "cyberkali"
$Banner = @"
 _            __
(_)___  _  __/ /_  _____
/ / __ \| |/_/ __ \/ ___/
/ / /_/ />  </ /_/ / /
/_/ .___/_/|_/_.___/_/
  /_/
"@

function Show-Banner {
    $colors = @("Green", "DarkGreen", "Green", "DarkGreen", "Green", "DarkGreen")
    $i = 0
    foreach ($line in ($Banner -split "`n")) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $color = $colors[$i % $colors.Count]
        Write-Color $line $color
        $i++
    }
}

function Show-Divider {
    Write-Color "============================================================" "DarkGreen"
}

function Show-Help {
    Show-Banner
    Write-Color "$NomeFerramenta v$Versao - por $Autor" "Green"
    Show-Divider
    Write-Host ""
    Write-Host "Uso:"
    Write-Host "  .\localizar-ip.ps1 [opcoes] <ip>"
    Write-Host "  .\localizar-ip.ps1 [opcoes] -Batch arquivo.txt"
    Write-Host ""
    Write-Host "Opcoes:"
    Write-Host "  -Help                Mostra esta ajuda"
    Write-Host "  -Json                Saida em JSON"
    Write-Host "  -Out <arquivo>       Salva a saida em arquivo"
    Write-Host "  -Batch <arquivo>     Consulta varios IPs (1 por linha)"
    Write-Host "  -MeuIp               Detecta e consulta seu IP publico"
    Write-Host "  -MeuIpPrivado        Mostra o(s) IP(s) privado(s) local(is)"
    Write-Host "  -Map                 Mostra link do Google Maps"
    Write-Host "  -NoColor             Desativa cores no terminal"
    Write-Host ""
    Write-Host "Exemplos:"
    Write-Host "  .\localizar-ip.ps1 8.8.8.8"
    Write-Host "  .\localizar-ip.ps1 -Json 1.1.1.1"
    Write-Host "  .\localizar-ip.ps1 -Batch .\ips.txt -Out .\resultado.txt"
    Write-Host "  .\localizar-ip.ps1 -MeuIp -Map"
    Write-Host "  .\localizar-ip.ps1 -MeuIpPrivado"
    Write-Host "  .\localizar-ip.ps1 1"
}

function Invoke-NumericMenu {
    Show-Banner
    Write-Color "$NomeFerramenta v$Versao - por $Autor" "Green"
    Show-Divider
    Write-Host ""
    Write-Host "Escolha uma opcao:"
    Write-Host "  1) Consultar um IP"
    Write-Host "  2) Consultar meu IP publico (com mapa)"
    Write-Host "  3) Consultar um IP com mapa"
    Write-Host "  4) Consulta em lote por arquivo"
    Write-Host "  5) Consultar meu IP privado (LAN)"
    Write-Host "  6) Mostrar ajuda"
    Write-Host "  0) Sair"
    Show-Divider
    $opt = Read-Host "Opcao"

    $cfg = [ordered]@{
        Ip    = $null
        Help  = $false
        Json  = $false
        Out   = $null
        Batch = $null
        MeuIp = $false
        MeuIpPrivado = $false
        Map   = $false
        Exit  = $false
    }

    switch ($opt) {
        "1" { $cfg.Ip = Read-Host "Digite o IP" }
        "2" { $cfg.MeuIp = $true; $cfg.Map = $true }
        "3" { $cfg.Map = $true; $cfg.Ip = Read-Host "Digite o IP" }
        "4" { $cfg.Batch = Read-Host "Digite o arquivo de lote" }
        "5" { $cfg.MeuIpPrivado = $true }
        "6" { $cfg.Help = $true }
        "0" { $cfg.Exit = $true }
        default { throw "Opcao invalida." }
    }

    if (-not $cfg.Help -and -not $cfg.Exit) {
        $qJson = Read-Host "Saida em JSON? (s/N)"
        if ($qJson -match "^[sS]$") { $cfg.Json = $true }

        $qOut = Read-Host "Salvar em arquivo? (s/N)"
        if ($qOut -match "^[sS]$") {
            $cfg.Out = Read-Host "Nome do arquivo de saida"
        }
    }

    return [PSCustomObject]$cfg
}

function Write-Color {
    param(
        [string]$Text,
        [ValidateSet("Green", "DarkGreen", "Red", "Yellow", "Default")]
        [string]$Color = "Default"
    )
    if ($NoColor -or $Color -eq "Default") {
        Write-Host $Text
    }
    else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Test-IpValido {
    param([string]$Valor)
    $parsed = $null
    return [System.Net.IPAddress]::TryParse($Valor, [ref]$parsed)
}

function Test-IpPrivado {
    param([string]$Valor)
    $parsed = $null
    if (-not [System.Net.IPAddress]::TryParse($Valor, [ref]$parsed)) { return $false }
    if ($parsed.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) { return $false }
    $b = $parsed.GetAddressBytes()
    if ($b[0] -eq 10) { return $true }
    if ($b[0] -eq 172 -and $b[1] -ge 16 -and $b[1] -le 31) { return $true }
    if ($b[0] -eq 192 -and $b[1] -eq 168) { return $true }
    return $false
}

function Get-FaixaPrivada {
    param([string]$Valor)
    $parsed = $null
    if (-not [System.Net.IPAddress]::TryParse($Valor, [ref]$parsed)) { return "desconhecida" }
    $b = $parsed.GetAddressBytes()
    if ($b[0] -eq 10) { return "10.0.0.0/8" }
    if ($b[0] -eq 172 -and $b[1] -ge 16 -and $b[1] -le 31) { return "172.16.0.0/12" }
    if ($b[0] -eq 192 -and $b[1] -eq 168) { return "192.168.0.0/16" }
    return "desconhecida"
}

function Get-IpPrivadosLocais {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -and (Test-IpPrivado -Valor $_.IPAddress) } |
        Select-Object IPAddress, InterfaceAlias, PrefixLength
    return $ips
}

function Get-RespostaApi {
    param([string]$IpConsulta)
    $url = "https://ipwho.is/$IpConsulta"
    return Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
}

function Get-IpPublico {
    $resp = Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -Method Get -ErrorAction Stop
    return $resp.ip
}

function To-ResultadoObjeto {
    param(
        $Api,
        [bool]$IncludeMap = $false
    )
    $org = if ($Api.connection.org -eq "Google LLC") { "cyber" } else { $Api.connection.org }
    $obj = [ordered]@{
        ip          = $Api.ip
        pais        = $Api.country
        regiao      = $Api.region
        cidade      = $Api.city
        cep         = $Api.postal
        latitude    = $Api.latitude
        longitude   = $Api.longitude
        fuso        = $Api.timezone.id
        isp         = $Api.connection.isp
        organizacao = $org
    }
    if ($IncludeMap) {
        $obj["mapa_url"] = "https://www.google.com/maps?q=$($Api.latitude),$($Api.longitude)"
    }
    [PSCustomObject]$obj
}

function To-ResultadoPrivado {
    param(
        [string]$IpPrivado,
        [string]$InterfaceAlias = $null,
        [int]$PrefixLength = $null
    )
    $obj = [ordered]@{
        ip    = $IpPrivado
        tipo  = "privado"
        faixa = (Get-FaixaPrivada -Valor $IpPrivado)
    }
    if (-not [string]::IsNullOrWhiteSpace($InterfaceAlias)) {
        $obj["interface"] = $InterfaceAlias
    }
    if ($PrefixLength -gt 0) {
        $obj["prefixo"] = $PrefixLength
    }
    [PSCustomObject]$obj
}

function To-TextoResultado {
    param($Obj)
    @(
        "IP:        $($Obj.ip)"
        if ($Obj.PSObject.Properties.Name -contains "tipo") {
            "Tipo:      $($Obj.tipo)"
        }
        if ($Obj.PSObject.Properties.Name -contains "faixa") {
            "Faixa:     $($Obj.faixa)"
        }
        if ($Obj.PSObject.Properties.Name -contains "interface") {
            "Interface: $($Obj.interface)"
        }
        if ($Obj.PSObject.Properties.Name -contains "prefixo") {
            "Prefixo:   /$($Obj.prefixo)"
        }
        if ($Obj.PSObject.Properties.Name -contains "pais") {
            "Pais:      $($Obj.pais)"
        }
        if ($Obj.PSObject.Properties.Name -contains "regiao") {
            "Regiao:    $($Obj.regiao)"
        }
        if ($Obj.PSObject.Properties.Name -contains "cidade") {
            "Cidade:    $($Obj.cidade)"
        }
        if ($Obj.PSObject.Properties.Name -contains "cep") {
            "CEP:       $($Obj.cep)"
        }
        if ($Obj.PSObject.Properties.Name -contains "latitude") {
            "Latitude:  $($Obj.latitude)"
        }
        if ($Obj.PSObject.Properties.Name -contains "longitude") {
            "Longitude: $($Obj.longitude)"
        }
        if ($Obj.PSObject.Properties.Name -contains "fuso") {
            "Fuso:      $($Obj.fuso)"
        }
        if ($Obj.PSObject.Properties.Name -contains "isp") {
            "ISP:       $($Obj.isp)"
        }
        if ($Obj.PSObject.Properties.Name -contains "organizacao") {
            "Organizacao: $($Obj.organizacao)"
        }
        if ($Obj.PSObject.Properties.Name -contains "mapa_url") {
            "Mapa:      $($Obj.mapa_url)"
        }
    ) -join [Environment]::NewLine
}

if ($Help) {
    Show-Help
    exit 0
}

$hasAnyOption = $Help -or $Json -or (-not [string]::IsNullOrWhiteSpace($Out)) -or (-not [string]::IsNullOrWhiteSpace($Batch)) -or $NoColor -or $MeuIp -or $MeuIpPrivado -or $Map

if (-not $hasAnyOption -and ($Ip -match "^[0-6]$")) {
    switch ($Ip) {
        "0" { exit 0 }
        "1" { $Ip = Read-Host "Digite o IP" }
        "2" { $Ip = $null; $MeuIp = $true; $Map = $true }
        "3" { $Ip = Read-Host "Digite o IP"; $Map = $true }
        "4" { $Ip = $null; $Batch = Read-Host "Digite o arquivo de lote" }
        "5" { $MeuIpPrivado = $true }
        "6" { $Help = $true }
    }
}

if ([string]::IsNullOrWhiteSpace($Ip) -and [string]::IsNullOrWhiteSpace($Batch) -and -not $MeuIp -and -not $MeuIpPrivado -and -not $Help) {
    try {
        $menu = Invoke-NumericMenu
    }
    catch {
        Write-Error $_.Exception.Message
        exit 1
    }

    if ($menu.Exit) { exit 0 }
    if ($menu.Help) { $Help = $true }
    if ($menu.Json) { $Json = $true }
    if (-not [string]::IsNullOrWhiteSpace($menu.Out)) { $Out = $menu.Out }
    if (-not [string]::IsNullOrWhiteSpace($menu.Batch)) { $Batch = $menu.Batch }
    if ($menu.MeuIp) { $MeuIp = $true }
    if ($menu.MeuIpPrivado) { $MeuIpPrivado = $true }
    if ($menu.Map) { $Map = $true }
    if (-not [string]::IsNullOrWhiteSpace($menu.Ip)) { $Ip = $menu.Ip }
}

if ($Help) {
    Show-Help
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Ip) -and [string]::IsNullOrWhiteSpace($Batch) -and -not $MeuIp -and -not $MeuIpPrivado) {
    Show-Help
    exit 1
}

$modoCount = 0
if (-not [string]::IsNullOrWhiteSpace($Ip)) { $modoCount++ }
if (-not [string]::IsNullOrWhiteSpace($Batch)) { $modoCount++ }
if ($MeuIp) { $modoCount++ }
if ($MeuIpPrivado) { $modoCount++ }
if ($modoCount -ne 1) {
    Write-Error "Use apenas um modo: <ip> ou -Batch <arquivo> ou -MeuIp ou -MeuIpPrivado."
    exit 1
}

if ($MeuIp) {
    try {
        $Ip = Get-IpPublico
    }
    catch {
        Write-Error "Nao foi possivel detectar seu IP publico. Detalhes: $($_.Exception.Message)"
        exit 1
    }
}

if ($MeuIpPrivado) {
    $privados = Get-IpPrivadosLocais
    if (-not $privados -or $privados.Count -eq 0) {
        Write-Error "Nao foi possivel detectar IP privado local."
        exit 1
    }
}

if (-not $Json) {
    Show-Banner
    Write-Color "$NomeFerramenta v$Versao - por $Autor" "Green"
    if ($MeuIp) {
        Write-Color "Consultando localizacao para o seu IP publico: $Ip" "DarkGreen"
    }
    elseif ($MeuIpPrivado) {
        Write-Color "Consultando IP(s) privado(s) local(is)" "DarkGreen"
    }
    elseif (-not [string]::IsNullOrWhiteSpace($Ip)) {
        Write-Color "Consultando localizacao para o IP: $Ip" "DarkGreen"
    }
    else {
        Write-Color "Consultando localizacao em lote: $Batch" "DarkGreen"
    }
    Show-Divider
    Write-Host ""
}

$saidaFinal = ""

if ($MeuIpPrivado) {
    $objs = @()
    foreach ($p in $privados) {
        $objs += To-ResultadoPrivado -IpPrivado $p.IPAddress -InterfaceAlias $p.InterfaceAlias -PrefixLength $p.PrefixLength
    }
    if ($Json) {
        $saidaFinal = $objs | ConvertTo-Json -Depth 5
    }
    else {
        $blocos = @()
        foreach ($o in $objs) {
            $blocos += (To-TextoResultado -Obj $o)
        }
        $saidaFinal = $blocos -join "`n--------------------------`n"
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($Ip)) {
    if (-not (Test-IpValido -Valor $Ip)) {
        Write-Error "IP invalido: '$Ip'. Exemplo de uso: .\localizar-ip.ps1 8.8.8.8"
        exit 1
    }

    if (Test-IpPrivado -Valor $Ip) {
        $iface = Get-NetIPAddress -AddressFamily IPv4 -IPAddress $Ip -ErrorAction SilentlyContinue | Select-Object -First 1
        $obj = To-ResultadoPrivado -IpPrivado $Ip -InterfaceAlias $iface.InterfaceAlias -PrefixLength $iface.PrefixLength
    }
    else {
        try {
            $response = Get-RespostaApi -IpConsulta $Ip
        }
        catch {
            Write-Error "Falha ao consultar a API de localizacao por IP. Detalhes: $($_.Exception.Message)"
            exit 1
        }

        if (-not $response.success) {
            $msg = if ($response.message) { $response.message } else { "erro desconhecido" }
            Write-Error "Nao foi possivel localizar o IP '$Ip': $msg"
            exit 1
        }

        $obj = To-ResultadoObjeto -Api $response -IncludeMap:$Map
    }
    if ($Json) {
        $saidaFinal = $obj | ConvertTo-Json -Depth 5
    }
    else {
        $saidaFinal = To-TextoResultado -Obj $obj
    }
}
else {
    if (-not (Test-Path -Path $Batch)) {
        Write-Error "Arquivo de lote nao encontrado: $Batch"
        exit 1
    }

    $linhas = Get-Content -Path $Batch | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith("#") }

    if ($Json) {
        $itens = @()
        foreach ($ipLinha in $linhas) {
            if (-not (Test-IpValido -Valor $ipLinha)) {
                $itens += [PSCustomObject]@{ ip = $ipLinha; erro = "IP invalido" }
                continue
            }
            try {
                if (Test-IpPrivado -Valor $ipLinha) {
                    $iface = Get-NetIPAddress -AddressFamily IPv4 -IPAddress $ipLinha -ErrorAction SilentlyContinue | Select-Object -First 1
                    $itens += To-ResultadoPrivado -IpPrivado $ipLinha -InterfaceAlias $iface.InterfaceAlias -PrefixLength $iface.PrefixLength
                }
                else {
                    $resp = Get-RespostaApi -IpConsulta $ipLinha
                    if ($resp.success) {
                        $itens += To-ResultadoObjeto -Api $resp -IncludeMap:$Map
                    }
                    else {
                        $msg = if ($resp.message) { $resp.message } else { "erro desconhecido" }
                        $itens += [PSCustomObject]@{ ip = $ipLinha; erro = $msg }
                    }
                }
            }
            catch {
                $itens += [PSCustomObject]@{ ip = $ipLinha; erro = $_.Exception.Message }
            }
        }
        $saidaFinal = $itens | ConvertTo-Json -Depth 5
    }
    else {
        $blocos = @()
        foreach ($ipLinha in $linhas) {
            if (-not (Test-IpValido -Valor $ipLinha)) {
                $blocos += "IP consultado: $ipLinha`nERRO: IP invalido"
                continue
            }
            try {
                if (Test-IpPrivado -Valor $ipLinha) {
                    $iface = Get-NetIPAddress -AddressFamily IPv4 -IPAddress $ipLinha -ErrorAction SilentlyContinue | Select-Object -First 1
                    $obj = To-ResultadoPrivado -IpPrivado $ipLinha -InterfaceAlias $iface.InterfaceAlias -PrefixLength $iface.PrefixLength
                    $blocos += "IP consultado: $ipLinha`n$(To-TextoResultado -Obj $obj)"
                }
                else {
                    $resp = Get-RespostaApi -IpConsulta $ipLinha
                    if ($resp.success) {
                        $obj = To-ResultadoObjeto -Api $resp -IncludeMap:$Map
                        $blocos += "IP consultado: $ipLinha`n$(To-TextoResultado -Obj $obj)"
                    }
                    else {
                        $msg = if ($resp.message) { $resp.message } else { "erro desconhecido" }
                        $blocos += "IP consultado: $ipLinha`nERRO: $msg"
                    }
                }
            }
            catch {
                $blocos += "IP consultado: $ipLinha`nERRO: $($_.Exception.Message)"
            }
        }
        $saidaFinal = $blocos -join "`n--------------------------`n"
    }
}

if (-not [string]::IsNullOrWhiteSpace($Out)) {
    $saidaFinal | Set-Content -Path $Out -Encoding UTF8
    if (-not $Json) {
        Write-Color "Saida salva em: $Out" "Green"
    }
}

Write-Output $saidaFinal

if (-not $Json) {
    Write-Host ""
    Show-Divider
    Write-Color "assinatura: $Autor" "Green"
}
