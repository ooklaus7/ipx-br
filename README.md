# ipx br

Ferramenta de localizacao por IP com:
- menu numerico
- modo `--meu-ip`
- link de mapa com `--map`
- latencia com `--ping`
- host reverso com `--host`
- exportacao CSV com `--export csv`
- historico com `--history`
- tema colorido e efeitos visuais no terminal
- intel basica com `--intel` (proxy/vpn/tor/hosting/score)
- relatorio TXT com `--report`
- notificacao webhook com `--notify <url>`
- auto update com `--update`
- screenshot de mapa com `--screenshot-map`
- alerta de anomalia com `--anomaly` (mudanca pais/org/asn)
- classificacao de risco visual (LOW/MED/HIGH/CRITICAL)
- tema por arquivo com `--theme-file`
- barra de progresso em lote
- relatorio HTML com `--report-html`
- saida texto/JSON
- consulta em lote

## Arquivos
- `localizar-ip.sh` (Linux/Kali)
- `localizar-ip.ps1` (Windows/PowerShell)

## Subir para GitHub (Windows PowerShell)
Execute dentro de `C:\Users\PICHAU\ipx-br`:

```powershell
cd C:\Users\PICHAU\ipx-br
git init
git add .
git commit -m "feat: ipx br v1.0.0"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/ipx-br.git
git push -u origin main
```

## Baixar no Kali
```bash
git clone https://github.com/SEU_USUARIO/ipx-br.git
cd ipx-br
chmod +x localizar-ip.sh
sudo apt update && sudo apt install -y curl jq python3
./localizar-ip.sh
```

## Uso rapido no Kali
```bash
./localizar-ip.sh 2
./localizar-ip.sh --ping --host 8.8.8.8
./localizar-ip.sh --intel 8.8.8.8
./localizar-ip.sh --map --screenshot-map 8.8.8.8
./localizar-ip.sh --anomaly 8.8.8.8
./localizar-ip.sh --intel --risk-visual 8.8.8.8
./localizar-ip.sh --report --report-file meu_relatorio.txt 8.8.8.8
./localizar-ip.sh --report-html --report-html-file meu_relatorio.html 8.8.8.8
./localizar-ip.sh --theme-file ~/.ipx-br-theme 8.8.8.8
./localizar-ip.sh --batch ips.txt --no-progress
./localizar-ip.sh --notify https://SEU-WEBHOOK 8.8.8.8
./localizar-ip.sh --update
./localizar-ip.sh --export csv --batch ips.txt --out resultado.csv
./localizar-ip.sh --history
./localizar-ip.sh --no-effects
./localizar-ip.sh --no-color
```

## Tema customizado
Crie `~/.ipx-br-theme`:

```bash
theme=cyber_blue
```

Presets disponiveis:
- `hacker_green`
- `amber`
- `cyber_blue`
