# ipx br

Ferramenta de localizacao por IP com:
- menu numerico
- modo `--meu-ip`
- link de mapa com `--map`
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
```
