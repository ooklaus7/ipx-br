#!/usr/bin/env bash
set -euo pipefail

NOME_FERRAMENTA="ipx br"
VERSAO="2.0.0"
AUTOR="cyberkali"
BANNER='
 _            __
(_)___  _  __/ /_  _____
/ / __ \| |/_/ __ \/ ___/
/ / /_/ />  </ /_/ / /
/_/ .___/_/|_/_.___/_/
  /_/
'

JSON_MODE=0
OUT_FILE=""
BATCH_FILE=""
THEME_FILE="${HOME}/.ipx-br-theme"
THEME_FILE_FALLBACK=""
THEME_PRESET=""
LIST_THEMES_MODE=0
IP=""
NO_COLOR=0
NO_EFFECTS=0
NO_PROGRESS=0
MEU_IP_MODE=0
MEU_IP_PRIVADO_MODE=0
MAP_MODE=0
SCREENSHOT_MAP_MODE=0
SCREENSHOT_MAP_FILE=""
PING_MODE=0
HOST_MODE=0
INTEL_MODE=0
ANOMALY_MODE=0
RISK_VISUAL_MODE=1
EXPORT_FORMAT=""
SHOW_HISTORY=0
HISTORY_FILE="${HOME}/.ipx-br-history.log"
ANOMALY_DB_FILE="${HOME}/.ipx-br-anomaly.db"
ANOMALY_ALERTS_FILE="${HOME}/.ipx-br-anomaly-alerts.log"
REPORT_MODE=0
REPORT_FILE=""
REPORT_HTML_MODE=0
REPORT_HTML_FILE=""
NOTIFY_URL=""
UPDATE_MODE=0

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_CYAN=$'\033[32m'
  C_GREEN=$'\033[32m'
  C_RED=$'\033[31m'
  C_YELLOW=$'\033[92m'
  C_MAGENTA=$'\033[92m'
  C_BLUE=$'\033[32m'
  C_WHITE=$'\033[37m'
  C_GREEN_NEON=$'\033[92m'
  C_GREEN_DARK=$'\033[32m'
  C_GREEN_DIM=$'\033[2;32m'
else
  C_RESET=""
  C_BOLD=""
  C_CYAN=""
  C_GREEN=""
  C_RED=""
  C_YELLOW=""
  C_MAGENTA=""
  C_BLUE=""
  C_WHITE=""
  C_GREEN_NEON=""
  C_GREEN_DARK=""
  C_GREEN_DIM=""
fi

set_theme_preset() {
  local preset="$1"
  case "$preset" in
    hacker_green|green|"")
      C_CYAN=$'\033[32m'; C_GREEN=$'\033[32m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[92m'
      C_MAGENTA=$'\033[92m'; C_BLUE=$'\033[32m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[92m'; C_GREEN_DARK=$'\033[32m'; C_GREEN_DIM=$'\033[2;32m'
      ;;
    amber)
      C_CYAN=$'\033[33m'; C_GREEN=$'\033[33m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[93m'
      C_MAGENTA=$'\033[93m'; C_BLUE=$'\033[33m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[93m'; C_GREEN_DARK=$'\033[33m'; C_GREEN_DIM=$'\033[2;33m'
      ;;
    cyber_blue)
      C_CYAN=$'\033[36m'; C_GREEN=$'\033[36m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[96m'
      C_MAGENTA=$'\033[94m'; C_BLUE=$'\033[34m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[96m'; C_GREEN_DARK=$'\033[36m'; C_GREEN_DIM=$'\033[2;36m'
      ;;
    red_alert)
      C_CYAN=$'\033[91m'; C_GREEN=$'\033[91m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[93m'
      C_MAGENTA=$'\033[95m'; C_BLUE=$'\033[91m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[91m'; C_GREEN_DARK=$'\033[31m'; C_GREEN_DIM=$'\033[2;31m'
      ;;
    violet_night)
      C_CYAN=$'\033[95m'; C_GREEN=$'\033[95m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[35m'
      C_MAGENTA=$'\033[95m'; C_BLUE=$'\033[35m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[95m'; C_GREEN_DARK=$'\033[35m'; C_GREEN_DIM=$'\033[2;35m'
      ;;
    ice_white)
      C_CYAN=$'\033[97m'; C_GREEN=$'\033[97m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[37m'
      C_MAGENTA=$'\033[97m'; C_BLUE=$'\033[97m'; C_WHITE=$'\033[97m'
      C_GREEN_NEON=$'\033[97m'; C_GREEN_DARK=$'\033[37m'; C_GREEN_DIM=$'\033[2;37m'
      ;;
    toxic_lime)
      C_CYAN=$'\033[92m'; C_GREEN=$'\033[92m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[93m'
      C_MAGENTA=$'\033[92m'; C_BLUE=$'\033[92m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[92m'; C_GREEN_DARK=$'\033[32m'; C_GREEN_DIM=$'\033[2;32m'
      ;;
    ocean_teal)
      C_CYAN=$'\033[96m'; C_GREEN=$'\033[96m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[36m'
      C_MAGENTA=$'\033[96m'; C_BLUE=$'\033[36m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[96m'; C_GREEN_DARK=$'\033[36m'; C_GREEN_DIM=$'\033[2;36m'
      ;;
    sunset_orange)
      C_CYAN=$'\033[93m'; C_GREEN=$'\033[93m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[33m'
      C_MAGENTA=$'\033[93m'; C_BLUE=$'\033[33m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[93m'; C_GREEN_DARK=$'\033[33m'; C_GREEN_DIM=$'\033[2;33m'
      ;;
    matrix_classic)
      C_CYAN=$'\033[32m'; C_GREEN=$'\033[92m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[92m'
      C_MAGENTA=$'\033[32m'; C_BLUE=$'\033[32m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[92m'; C_GREEN_DARK=$'\033[32m'; C_GREEN_DIM=$'\033[2;32m'
      ;;
    rose_pink)
      C_CYAN=$'\033[95m'; C_GREEN=$'\033[95m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[35m'
      C_MAGENTA=$'\033[95m'; C_BLUE=$'\033[95m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[95m'; C_GREEN_DARK=$'\033[35m'; C_GREEN_DIM=$'\033[2;35m'
      ;;
    gold_terminal)
      C_CYAN=$'\033[33m'; C_GREEN=$'\033[33m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[93m'
      C_MAGENTA=$'\033[33m'; C_BLUE=$'\033[33m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[93m'; C_GREEN_DARK=$'\033[33m'; C_GREEN_DIM=$'\033[2;33m'
      ;;
    mono)
      C_CYAN=$'\033[37m'; C_GREEN=$'\033[37m'; C_RED=$'\033[31m'; C_YELLOW=$'\033[37m'
      C_MAGENTA=$'\033[37m'; C_BLUE=$'\033[37m'; C_WHITE=$'\033[37m'
      C_GREEN_NEON=$'\033[37m'; C_GREEN_DARK=$'\033[37m'; C_GREEN_DIM=$'\033[2;37m'
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

list_themes() {
  cat <<'EOF'
hacker_green
amber
cyber_blue
red_alert
violet_night
ice_white
toxic_lime
ocean_teal
sunset_orange
matrix_classic
rose_pink
gold_terminal
mono
EOF
}

load_theme_file() {
  local source_file=""
  if [[ -f "$THEME_FILE" ]]; then
    source_file="$THEME_FILE"
  elif [[ -n "$THEME_FILE_FALLBACK" && -f "$THEME_FILE_FALLBACK" ]]; then
    source_file="$THEME_FILE_FALLBACK"
  fi
  [[ -z "$source_file" ]] && return 0
  local preset
  preset="$(awk -F'=' '/^[[:space:]]*theme[[:space:]]*=/{gsub(/[[:space:]]/,"",$2); print tolower($2); exit}' "$source_file")"
  if [[ -n "$preset" ]]; then
    if ! set_theme_preset "$preset"; then
      warn "Tema invalido em $source_file: '$preset' (use --list-themes)"
    fi
  fi
}

save_theme_persistent() {
  local preset="$1"
  local normalized
  normalized="$(echo "$preset" | tr '[:upper:]' '[:lower:]')"
  if ! set_theme_preset "$normalized"; then
    err "Tema invalido: '$preset' (use --list-themes)"
    return 1
  fi
  mkdir -p "$(dirname "$THEME_FILE")"
  printf "theme=%s\n" "$normalized" >"$THEME_FILE"
  ok "Tema salvo em $THEME_FILE: $normalized"
  return 0
}

render_progress() {
  local current="$1"
  local total="$2"
  local label="${3:-processando}"
  [[ $NO_PROGRESS -eq 1 || $NO_EFFECTS -eq 1 || ! -t 1 ]] && return 0
  [[ $total -le 0 ]] && return 0
  local width=28 filled pct bar
  pct=$(( current * 100 / total ))
  filled=$(( current * width / total ))
  bar="$(printf "%${filled}s" | tr ' ' '#')"
  bar+="$(printf "%$((width - filled))s" | tr ' ' '-')"
  printf "\r%s[%s] %3d%% (%d/%d) %s%s" "$C_GREEN_DARK" "$bar" "$pct" "$current" "$total" "$label" "$C_RESET" >&2
  if [[ $current -ge $total ]]; then
    printf "\n" >&2
  fi
}

print_divider() {
  [[ $JSON_MODE -eq 1 || "$EXPORT_FORMAT" == "csv" ]] && return 0
  printf "%s%s%s\n" "$C_GREEN_DIM" "============================================================" "$C_RESET"
}

type_line() {
  local text="$1"
  if [[ $NO_EFFECTS -eq 1 || ! -t 1 ]]; then
    echo "$text"
    return
  fi
  local i ch
  for (( i=0; i<${#text}; i++ )); do
    ch="${text:$i:1}"
    printf "%s" "$ch"
    sleep 0.004
  done
  printf "\n"
}

print_banner() {
  local colors=("$C_GREEN_NEON" "$C_GREEN_DARK" "$C_GREEN_NEON" "$C_GREEN_DARK" "$C_GREEN_NEON" "$C_GREEN_DARK" "$C_GREEN_NEON")
  local i=0
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    printf "%s%s%s\n" "${colors[$i]}" "$line" "$C_RESET"
    i=$(( (i + 1) % ${#colors[@]} ))
  done <<< "$BANNER"
}

run_numeric_menu() {
  print_banner
  echo "${C_BOLD}${C_GREEN_NEON}${NOME_FERRAMENTA} v${VERSAO} - por ${AUTOR}${C_RESET}"
  print_divider
  echo
  echo "Escolha uma opcao:"
  echo "  1) Consultar um IP"
  echo "  2) Consultar meu IP publico (com mapa)"
  echo "  3) Consultar um IP com mapa"
  echo "  4) Consulta em lote por arquivo"
  echo "  5) Mostrar historico"
  echo "  6) Atualizar ferramenta"
  echo "  7) Mostrar ajuda"
  echo "  8) Escolher tema"
  echo "  9) Consultar meu IP privado (LAN)"
  echo "  0) Sair"
  print_divider
  read -r -p "Opcao: " opt

  case "$opt" in
    1)
      read -r -p "Digite o IP: " m_ip
      set -- "$m_ip"
      ;;
    2)
      set -- --meu-ip --map
      ;;
    3)
      read -r -p "Digite o IP: " m_ip
      set -- --map "$m_ip"
      ;;
    4)
      read -r -p "Digite o arquivo de lote: " m_file
      set -- --batch "$m_file"
      ;;
    5)
      set -- --history
      ;;
    6)
      set -- --update
      ;;
    7)
      set -- --help
      ;;
    8)
      echo
      echo "Temas disponiveis:"
      list_themes | sed 's/^/  - /'
      read -r -p "Digite o nome do tema: " m_theme
      save_theme_persistent "$m_theme" || exit 1
      exit 0
      ;;
    9)
      set -- --meu-ip-privado
      ;;
    0)
      exit 0
      ;;
    *)
      echo "Opcao invalida."
      exit 1
      ;;
  esac

  if [[ "$1" != "--help" && "$1" != "--history" && "$1" != "--update" ]]; then
    read -r -p "Saida em JSON? (s/N): " m_json
    if [[ "$m_json" =~ ^[sS]$ ]]; then
      set -- --json "$@"
    fi

    read -r -p "Incluir ping? (s/N): " m_ping
    if [[ "$m_ping" =~ ^[sS]$ ]]; then
      set -- --ping "$@"
    fi

    read -r -p "Incluir host reverso? (s/N): " m_host
    if [[ "$m_host" =~ ^[sS]$ ]]; then
      set -- --host "$@"
    fi

    read -r -p "Incluir intel (vpn/proxy/tor)? (s/N): " m_intel
    if [[ "$m_intel" =~ ^[sS]$ ]]; then
      set -- --intel "$@"
    fi

    read -r -p "Exportar em CSV? (s/N): " m_csv
    if [[ "$m_csv" =~ ^[sS]$ ]]; then
      set -- --export csv "$@"
    fi

    read -r -p "Salvar em arquivo? (s/N): " m_out
    if [[ "$m_out" =~ ^[sS]$ ]]; then
      read -r -p "Nome do arquivo de saida: " m_out_file
      if [[ -n "$m_out_file" ]]; then
        set -- --out "$m_out_file" "$@"
      fi
    fi

    read -r -p "Enviar para webhook? (s/N): " m_notify
    if [[ "$m_notify" =~ ^[sS]$ ]]; then
      read -r -p "URL do webhook: " m_notify_url
      if [[ -n "$m_notify_url" ]]; then
        set -- --notify "$m_notify_url" "$@"
      fi
    fi
  fi

  MENU_ARGS=("$@")
}

print_help() {
  echo "$BANNER"
  echo "${NOME_FERRAMENTA} v${VERSAO} - por ${AUTOR}"
  echo
  echo "Uso:"
  echo "  $0 [opcoes] <ip>"
  echo "  $0 [opcoes] --batch arquivo.txt"
  echo
  echo "Opcoes:"
  echo "  -h, --help          Mostra esta ajuda"
  echo "  --json              Saida em JSON"
  echo "  --out <arquivo>     Salva a saida em arquivo"
  echo "  --batch <arquivo>   Consulta varios IPs (1 por linha)"
  echo "  --meu-ip            Detecta e consulta seu IP publico"
  echo "  --meu-ip-privado    Mostra o(s) IP(s) privado(s) local(is)"
  echo "  --map               Mostra link do Google Maps"
  echo "  --screenshot-map    Salva imagem estatica do mapa"
  echo "  --screenshot-file   Nome base do arquivo de mapa (png)"
  echo "  --ping              Adiciona latencia media (ms)"
  echo "  --host              Adiciona host reverso (PTR)"
  echo "  --intel             Adiciona analise de risco basica"
  echo "  --anomaly           Alerta mudanca de pais/org/asn"
  echo "  --risk-visual       Mostra classificacao de risco"
  echo "  --no-risk-visual    Oculta classificacao de risco"
  echo "  --export csv        Exporta resultado em CSV"
  echo "  --history           Mostra historico de consultas"
  echo "  --report            Gera relatorio em TXT"
  echo "  --report-file <arq> Define nome do relatorio (usa com --report)"
  echo "  --report-html       Gera relatorio HTML"
  echo "  --report-html-file  Define nome do relatorio HTML"
  echo "  --notify <url>      Envia resultado para webhook"
  echo "  --update            Atualiza via git pull"
  echo "  --theme <nome>      Define tema para esta execucao"
  echo "  --list-themes       Lista temas disponiveis"
  echo "  --theme-file <arq>  Arquivo de tema (padrao: ~/.ipx-br-theme)"
  echo "  --no-progress       Desativa barra de progresso em lote"
  echo "  --no-color          Desativa cores no terminal"
  echo "  --no-effects        Desativa efeitos visuais"
  echo
  echo "Exemplos:"
  echo "  $0 8.8.8.8"
  echo "  $0 --json 1.1.1.1"
  echo "  $0 --batch ips.txt --out resultado.txt"
  echo "  $0 --meu-ip --map"
  echo "  $0 --meu-ip-privado"
  echo "  $0 --screenshot-map --map 8.8.8.8"
  echo "  $0 --ping --host 8.8.8.8"
  echo "  $0 --intel --report 8.8.8.8"
  echo "  $0 --intel --risk-visual 8.8.8.8"
  echo "  $0 --report-html --report-html-file relatorio.html 8.8.8.8"
  echo "  $0 --theme cyber_blue 8.8.8.8"
  echo "  $0 --list-themes"
  echo "  $0 --notify https://SEU-WEBHOOK 8.8.8.8"
  echo "  $0 --update"
  echo "  $0 --export csv --batch ips.txt"
  echo "  $0 1              # abre fluxo numerico"
  echo "  $0 8              # abre submenu de temas"
}

info() { echo "${C_CYAN}$*${C_RESET}"; }
ok() { echo "${C_GREEN}$*${C_RESET}"; }
warn() { echo "${C_YELLOW}$*${C_RESET}"; }
err() { echo "${C_RED}$*${C_RESET}" >&2; }

if [[ $# -eq 0 ]]; then
  run_numeric_menu
  set -- "${MENU_ARGS[@]}"
fi

if [[ $# -gt 0 ]]; then
  case "$1" in
    0)
      exit 0
      ;;
    1)
      shift
      if [[ $# -eq 0 ]]; then
        read -r -p "Digite o IP: " n_ip
      else
        n_ip="$1"
      fi
      set -- "$n_ip"
      ;;
    2)
      shift
      set -- --meu-ip --map "$@"
      ;;
    3)
      shift
      if [[ $# -eq 0 ]]; then
        read -r -p "Digite o IP: " n_ip
      else
        n_ip="$1"
      fi
      set -- --map "$n_ip"
      ;;
    4)
      shift
      if [[ $# -eq 0 ]]; then
        read -r -p "Digite o arquivo de lote: " n_file
      else
        n_file="$1"
      fi
      set -- --batch "$n_file"
      ;;
    5)
      set -- --history
      ;;
    6)
      set -- --update
      ;;
    7)
      set -- --help
      ;;
    8)
      echo
      echo "Temas disponiveis:"
      list_themes | sed 's/^/  - /'
      read -r -p "Digite o nome do tema: " n_theme
      save_theme_persistent "$n_theme" || exit 1
      exit 0
      ;;
    9)
      set -- --meu-ip-privado
      ;;
  esac
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_help
      exit 0
      ;;
    --json)
      JSON_MODE=1
      shift
      ;;
    --out)
      [[ $# -lt 2 ]] && { err "Falta o valor de --out"; exit 1; }
      OUT_FILE="$2"
      shift 2
      ;;
    --batch)
      [[ $# -lt 2 ]] && { err "Falta o valor de --batch"; exit 1; }
      BATCH_FILE="$2"
      shift 2
      ;;
    --meu-ip)
      MEU_IP_MODE=1
      shift
      ;;
    --meu-ip-privado)
      MEU_IP_PRIVADO_MODE=1
      shift
      ;;
    --map)
      MAP_MODE=1
      shift
      ;;
    --screenshot-map)
      SCREENSHOT_MAP_MODE=1
      shift
      ;;
    --screenshot-file)
      [[ $# -lt 2 ]] && { err "Falta o valor de --screenshot-file"; exit 1; }
      SCREENSHOT_MAP_FILE="$2"
      shift 2
      ;;
    --ping)
      PING_MODE=1
      shift
      ;;
    --host)
      HOST_MODE=1
      shift
      ;;
    --intel)
      INTEL_MODE=1
      shift
      ;;
    --anomaly)
      ANOMALY_MODE=1
      shift
      ;;
    --risk-visual)
      RISK_VISUAL_MODE=1
      shift
      ;;
    --no-risk-visual)
      RISK_VISUAL_MODE=0
      shift
      ;;
    --export)
      [[ $# -lt 2 ]] && { err "Falta o valor de --export"; exit 1; }
      EXPORT_FORMAT="$2"
      shift 2
      ;;
    --report)
      REPORT_MODE=1
      shift
      ;;
    --report-file)
      [[ $# -lt 2 ]] && { err "Falta o valor de --report-file"; exit 1; }
      REPORT_FILE="$2"
      shift 2
      ;;
    --report-html)
      REPORT_HTML_MODE=1
      shift
      ;;
    --report-html-file)
      [[ $# -lt 2 ]] && { err "Falta o valor de --report-html-file"; exit 1; }
      REPORT_HTML_FILE="$2"
      shift 2
      ;;
    --notify)
      [[ $# -lt 2 ]] && { err "Falta a URL de --notify"; exit 1; }
      NOTIFY_URL="$2"
      shift 2
      ;;
    --update)
      UPDATE_MODE=1
      shift
      ;;
    --theme)
      [[ $# -lt 2 ]] && { err "Falta o valor de --theme"; exit 1; }
      THEME_PRESET="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
      shift 2
      ;;
    --list-themes)
      LIST_THEMES_MODE=1
      shift
      ;;
    --theme-file)
      [[ $# -lt 2 ]] && { err "Falta o valor de --theme-file"; exit 1; }
      THEME_FILE="$2"
      shift 2
      ;;
    --history)
      SHOW_HISTORY=1
      shift
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    --no-effects)
      NO_EFFECTS=1
      shift
      ;;
    --no-progress)
      NO_PROGRESS=1
      shift
      ;;
    -*)
      err "Opcao invalida: $1"
      print_help
      exit 1
      ;;
    *)
      if [[ -z "$IP" ]]; then
        IP="$1"
      else
        err "Argumento extra nao esperado: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE_FALLBACK="${SCRIPT_DIR}/theme.default"

if [[ $LIST_THEMES_MODE -eq 1 ]]; then
  list_themes
  exit 0
fi

if [[ -n "$THEME_PRESET" ]]; then
  if ! set_theme_preset "$THEME_PRESET"; then
    err "Tema invalido: '$THEME_PRESET' (use --list-themes)"
    exit 1
  fi
else
  load_theme_file
fi

if [[ $NO_COLOR -eq 1 ]]; then
  C_RESET=""; C_BOLD=""; C_CYAN=""; C_GREEN=""; C_RED=""; C_YELLOW=""; C_MAGENTA=""; C_BLUE=""; C_WHITE=""; C_GREEN_NEON=""; C_GREEN_DARK=""; C_GREEN_DIM=""
fi

run_update() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if ! command -v git >/dev/null 2>&1; then
    err "Git nao encontrado. Instale com: sudo apt install -y git"
    return 1
  fi
  if [[ ! -d "$script_dir/.git" ]]; then
    err "Repositorio git nao encontrado em: $script_dir"
    return 1
  fi
  info "Atualizando repositorio em: $script_dir"
  if git -C "$script_dir" pull --ff-only; then
    ok "Atualizacao concluida."
    return 0
  fi
  err "Falha ao atualizar via git pull."
  return 1
}

if [[ $UPDATE_MODE -eq 1 ]]; then
  run_update
  exit $?
fi

if ! command -v curl >/dev/null 2>&1; then
  err "Erro: curl nao encontrado. Instale com: sudo apt install -y curl"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  err "Erro: jq nao encontrado. Instale com: sudo apt install -y jq"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  err "Erro: python3 nao encontrado. Instale com: sudo apt install -y python3"
  exit 1
fi

if [[ $PING_MODE -eq 1 ]] && ! command -v ping >/dev/null 2>&1; then
  err "Erro: ping nao encontrado. Instale com: sudo apt install -y iputils-ping"
  exit 1
fi

if [[ $HOST_MODE -eq 1 ]] && ! command -v getent >/dev/null 2>&1; then
  err "Erro: getent nao encontrado."
  exit 1
fi

if [[ -n "$EXPORT_FORMAT" && "$EXPORT_FORMAT" != "csv" ]]; then
  err "Formato de exportacao invalido: $EXPORT_FORMAT (use: csv)"
  exit 1
fi

if [[ -n "$EXPORT_FORMAT" && $JSON_MODE -eq 1 ]]; then
  err "Use apenas um formato de saida: --json ou --export csv."
  exit 1
fi

if [[ -n "$SCREENSHOT_MAP_FILE" ]]; then
  SCREENSHOT_MAP_MODE=1
fi

if [[ -n "$REPORT_FILE" ]]; then
  REPORT_MODE=1
fi

if [[ -n "$REPORT_HTML_FILE" ]]; then
  REPORT_HTML_MODE=1
fi

if [[ -n "$NOTIFY_URL" && ! "$NOTIFY_URL" =~ ^https?:// ]]; then
  err "URL de webhook invalida: $NOTIFY_URL"
  exit 1
fi

if [[ $SCREENSHOT_MAP_MODE -eq 1 && ! "$SCREENSHOT_MAP_FILE" =~ \.png$ && -n "$SCREENSHOT_MAP_FILE" ]]; then
  SCREENSHOT_MAP_FILE="${SCREENSHOT_MAP_FILE}.png"
fi

if [[ $REPORT_HTML_MODE -eq 1 && -n "$REPORT_HTML_FILE" && ! "$REPORT_HTML_FILE" =~ \.html?$ ]]; then
  REPORT_HTML_FILE="${REPORT_HTML_FILE}.html"
fi

if [[ $SHOW_HISTORY -eq 1 ]]; then
  if [[ -f "$HISTORY_FILE" ]]; then
    cat "$HISTORY_FILE"
  else
    warn "Historico vazio: $HISTORY_FILE"
  fi
  exit 0
fi

validate_ip() {
  local ip="$1"
  python3 - "$ip" >/dev/null 2>&1 <<'PY'
import ipaddress
import sys
ipaddress.ip_address(sys.argv[1])
PY
}

is_private_ip() {
  local ip="$1"
  python3 - "$ip" >/dev/null 2>&1 <<'PY'
import ipaddress
import sys
print(int(ipaddress.ip_address(sys.argv[1]).is_private))
PY
}

private_range_label() {
  local ip="$1"
  local o1 o2
  IFS='.' read -r o1 o2 _ _ <<<"$ip"
  if [[ "$o1" == "10" ]]; then
    echo "10.0.0.0/8"
    return
  fi
  if [[ "$o1" == "172" && "$o2" -ge 16 && "$o2" -le 31 ]]; then
    echo "172.16.0.0/12"
    return
  fi
  if [[ "$o1" == "192" && "$o2" == "168" ]]; then
    echo "192.168.0.0/16"
    return
  fi
  echo "desconhecida"
}

get_private_meta() {
  local ip="$1"
  local iface="" prefix=""
  if command -v ip >/dev/null 2>&1; then
    local line cidr
    line="$(ip -4 -o addr show 2>/dev/null | awk -v ip="$ip" '$4 ~ "^"ip"/" {print $2"\t"$4; exit}')"
    if [[ -n "$line" ]]; then
      iface="${line%%$'\t'*}"
      cidr="${line#*$'\t'}"
      prefix="${cidr#*/}"
    fi
  fi
  printf "%s\t%s\n" "$iface" "$prefix"
}

get_private_ips_list() {
  python3 - <<'PY'
import ipaddress
import shutil
import subprocess
ips=[]
if shutil.which("ip"):
  out = subprocess.check_output(["ip","-4","-o","addr","show","scope","global"], text=True, stderr=subprocess.DEVNULL)
  for line in out.splitlines():
    parts=line.split()
    if len(parts) >= 4:
      iface=parts[1]
      cidr=parts[3]
      ip=cidr.split("/")[0]
      prefix=cidr.split("/")[1]
      try:
        ip_obj=ipaddress.ip_address(ip)
      except ValueError:
        continue
      if ip_obj.is_private:
        ips.append((ip,prefix,iface))
elif shutil.which("hostname"):
  out = subprocess.check_output(["hostname","-I"], text=True, stderr=subprocess.DEVNULL)
  for ip in out.split():
    try:
      ip_obj=ipaddress.ip_address(ip)
    except ValueError:
      continue
    if ip_obj.is_private:
      ips.append((ip,"",""))
for ip,prefix,iface in ips:
  print(f"{ip}\t{prefix}\t{iface}")
PY
}

private_to_json() {
  local ip="$1" faixa="$2" iface="$3" prefix="$4"
  jq -nc --arg ip "$ip" --arg faixa "$faixa" --arg iface "$iface" --arg prefix "$prefix" '
    {ip:$ip, tipo:"privado", faixa:$faixa}
    + (if $iface != "" then {interface:$iface} else {} end)
    + (if $prefix != "" then {prefixo: ($prefix|tonumber?)} else {} end)
  '
}

private_to_text() {
  local ip="$1" faixa="$2" iface="$3" prefix="$4"
  echo "IP:        $ip"
  echo "Tipo:      privado"
  echo "Faixa:     $faixa"
  [[ -n "$iface" ]] && echo "Interface: $iface"
  [[ -n "$prefix" ]] && echo "Prefixo:   /$prefix"
}

private_to_csv() {
  local ip="$1" faixa="$2"
  printf '"%s","PRIVADO","%s","","","","","","","privado","","","","","","","","",""\n' "$ip" "$faixa"
}

query_ip() {
  local ip="$1"
  local url="https://ipwho.is/${ip}"
  curl -sS "$url"
}

count_batch_ips() {
  local file="$1"
  awk '{
    line=$0
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
    if (line != "" && line !~ /^#/) c++
  } END {print c+0}' "$file"
}

get_meu_ip() {
  curl -sS "https://api.ipify.org?format=json" | jq -r '.ip // empty'
}

get_ping_ms() {
  local ip="$1"
  local avg
  avg="$(ping -c 3 -W 1 "$ip" 2>/dev/null | awk -F'/' '/^rtt|^round-trip/ {print $5}')"
  if [[ -z "$avg" ]]; then
    echo "n/a"
  else
    printf "%.2f" "$avg" 2>/dev/null || echo "$avg"
  fi
}

get_reverse_host() {
  local ip="$1"
  local host
  host="$(getent hosts "$ip" | awk '{print $2}' | head -n1 || true)"
  [[ -n "$host" ]] && echo "$host" || echo "n/a"
}

append_history() {
  local mode="$1"
  local target="$2"
  mkdir -p "$(dirname "$HISTORY_FILE")"
  printf "%s | %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$mode" "$target" >>"$HISTORY_FILE"
}

sanitize_filename() {
  local value="$1"
  echo "$value" | tr '[:space:]/\\:' '_' | tr -cd '[:alnum:]_.-'
}

build_screenshot_file() {
  local ip="$1"
  local base
  if [[ -n "$SCREENSHOT_MAP_FILE" ]]; then
    base="$SCREENSHOT_MAP_FILE"
  else
    base="ipx-map-${ip}-$(date '+%Y%m%d-%H%M%S').png"
  fi
  if [[ -n "$BATCH_FILE" ]]; then
    local safe_ip
    safe_ip="$(sanitize_filename "$ip")"
    if [[ "$base" == *.png ]]; then
      echo "${base%.png}-${safe_ip}.png"
    else
      echo "${base}-${safe_ip}.png"
    fi
  else
    echo "$base"
  fi
}

save_map_screenshot_from_resp() {
  local ip="$1"
  local resp_json="$2"
  local lat lon out_file url
  lat="$(jq -r '.latitude // empty' <<<"$resp_json")"
  lon="$(jq -r '.longitude // empty' <<<"$resp_json")"
  if [[ -z "$lat" || -z "$lon" ]]; then
    warn "Nao foi possivel gerar screenshot de mapa para $ip (lat/lon ausentes)."
    return 1
  fi
  out_file="$(build_screenshot_file "$ip")"
  url="https://staticmap.openstreetmap.de/staticmap.php?center=${lat},${lon}&zoom=12&size=900x520&markers=${lat},${lon},red-pushpin"
  if curl -sS "$url" -o "$out_file"; then
    ok "Screenshot do mapa salvo em: $out_file"
    return 0
  fi
  warn "Falha ao salvar screenshot do mapa para $ip."
  return 1
}

check_and_record_anomaly() {
  local ip="$1"
  local resp_json="$2"
  local country org asn now_line last_line last_country last_org last_asn changed detail
  country="$(jq -r '.country // ""' <<<"$resp_json")"
  org="$(jq -r 'if .connection.org == "Google LLC" then "cyber" else (.connection.org // "") end' <<<"$resp_json")"
  asn="$(jq -r '.connection.asn // .asn // ""' <<<"$resp_json")"

  mkdir -p "$(dirname "$ANOMALY_DB_FILE")"
  touch "$ANOMALY_DB_FILE"
  touch "$ANOMALY_ALERTS_FILE"

  last_line="$(awk -F'\t' -v ip="$ip" '$1==ip{line=$0} END{print line}' "$ANOMALY_DB_FILE")"
  changed=0
  detail=""
  if [[ -n "$last_line" ]]; then
    IFS=$'\t' read -r _ last_country last_org last_asn _ <<<"$last_line"
    if [[ "$country" != "$last_country" ]]; then
      changed=1
      detail+="pais: '${last_country}' -> '${country}'; "
    fi
    if [[ "$org" != "$last_org" ]]; then
      changed=1
      detail+="org: '${last_org}' -> '${org}'; "
    fi
    if [[ "$asn" != "$last_asn" ]]; then
      changed=1
      detail+="asn: '${last_asn}' -> '${asn}'; "
    fi
  fi

  now_line="$(printf "%s\t%s\t%s\t%s\t%s" "$ip" "$country" "$org" "$asn" "$(date '+%Y-%m-%d %H:%M:%S')")"
  printf "%s\n" "$now_line" >>"$ANOMALY_DB_FILE"

  if [[ $changed -eq 1 ]]; then
    warn "ANOMALIA detectada para $ip: ${detail}"
    printf "%s | %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$ip" "$detail" >>"$ANOMALY_ALERTS_FILE"
  fi
}

generate_report() {
  local content="$1"
  local report_path="$REPORT_FILE"
  if [[ -z "$report_path" ]]; then
    report_path="ipx-report-$(date '+%Y%m%d-%H%M%S').txt"
  fi
  {
    echo "ipx br v${VERSAO} - por ${AUTOR}"
    echo "gerado em: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "------------------------------------------------------------"
    printf "%s\n" "$content"
  } >"$report_path"
  ok "Relatorio salvo em: $report_path"
}

generate_html_report() {
  local content="$1"
  local html_path="$REPORT_HTML_FILE"
  local escaped
  if [[ -z "$html_path" ]]; then
    html_path="ipx-report-$(date '+%Y%m%d-%H%M%S').html"
  fi

  escaped="$(printf "%s" "$content" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')"

  cat >"$html_path" <<EOF
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>ipx br report</title>
  <style>
    :root {
      --bg: #07110b;
      --panel: #0b1a11;
      --line: #173424;
      --text: #a7ffb3;
      --neon: #5dff7a;
      --dim: #6ccf7b;
    }
    body {
      margin: 0;
      font-family: Consolas, "Courier New", monospace;
      background: radial-gradient(1200px 600px at 20% -10%, #123222 0%, var(--bg) 55%);
      color: var(--text);
      padding: 24px;
    }
    .card {
      max-width: 1100px;
      margin: 0 auto;
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 20px;
      box-shadow: 0 0 40px rgba(64, 255, 128, .08), inset 0 0 0 1px rgba(64, 255, 128, .06);
    }
    h1 { margin: 0 0 8px; color: var(--neon); font-size: 20px; }
    .meta { color: var(--dim); font-size: 13px; margin-bottom: 14px; }
    pre {
      margin: 0;
      background: #061009;
      border: 1px solid #13301f;
      border-radius: 10px;
      padding: 16px;
      overflow: auto;
      white-space: pre-wrap;
      word-break: break-word;
      line-height: 1.45;
      color: var(--text);
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>ipx br v${VERSAO} - por ${AUTOR}</h1>
    <div class="meta">gerado em: $(date '+%Y-%m-%d %H:%M:%S')</div>
    <pre>${escaped}</pre>
  </div>
</body>
</html>
EOF
  ok "Relatorio HTML salvo em: $html_path"
}

send_notify() {
  local content="$1"
  local payload
  payload="$(jq -Rn --arg text "$content" '{text: $text}')"
  if curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$NOTIFY_URL" >/dev/null; then
    ok "Notificacao enviada para webhook."
  else
    warn "Falha ao enviar notificacao para webhook."
  fi
}

to_compact_json() {
  local ping_value="$1"
  local host_value="$2"
  jq -c --argjson map "$MAP_MODE" --argjson ping "$PING_MODE" --argjson host "$HOST_MODE" --argjson intel "$INTEL_MODE" --arg ping_value "$ping_value" --arg host_value "$host_value" '
    def b2i(v): if v == true then 1 else 0 end;
    def risk: ((b2i(.security.proxy // false) + b2i(.security.vpn // false) + b2i(.security.tor // false) + b2i(.security.hosting // false)) * 25);
    ({
      ip,
      pais: .country,
      regiao: .region,
      cidade: .city,
      cep: .postal,
      latitude,
      longitude,
      fuso: .timezone.id,
      isp: .connection.isp,
      organizacao: (if .connection.org == "Google LLC" then "cyber" else .connection.org end)
    }
    + if $map then {mapa_url: ("https://www.google.com/maps?q=" + (.latitude|tostring) + "," + (.longitude|tostring))} else {} end
    + if $ping then {ping_ms: $ping_value} else {} end
    + if $host then {host_reverso: $host_value} else {} end
    + if $intel then {
        intel: {
          proxy: (.security.proxy // false),
          vpn: (.security.vpn // false),
          tor: (.security.tor // false),
          hosting: (.security.hosting // false),
          tipo_conexao: (.connection.type // "n/a"),
          risk_score: risk
        }
      } else {} end)
  '
}

to_text() {
  local ping_value="$1"
  local host_value="$2"
  jq -r --argjson map "$MAP_MODE" --argjson ping "$PING_MODE" --argjson host "$HOST_MODE" --argjson intel "$INTEL_MODE" --argjson risk_visual "$RISK_VISUAL_MODE" --arg ping_value "$ping_value" --arg host_value "$host_value" '
    def b2i(v): if v == true then 1 else 0 end;
    def risk: ((b2i(.security.proxy // false) + b2i(.security.vpn // false) + b2i(.security.tor // false) + b2i(.security.hosting // false)) * 25);
    def risk_label:
      if risk >= 75 then "CRITICAL"
      elif risk >= 50 then "HIGH"
      elif risk >= 25 then "MED"
      else "LOW" end;
    def btxt: if . then "sim" else "nao" end;
    ([
      "IP:        \(.ip // "")",
      "Pais:      \(.country // "")",
      "Regiao:    \(.region // "")",
      "Cidade:    \(.city // "")",
      "CEP:       \(.postal // "")",
      "Latitude:  \(.latitude // "")",
      "Longitude: \(.longitude // "")",
      "Fuso:      \(.timezone.id // "")",
      "ISP:       \(.connection.isp // "")",
      "Organizacao: \(if .connection.org == "Google LLC" then "cyber" else (.connection.org // "") end)"
    ] + if $ping then ["Ping (ms):  \($ping_value)"] else [] end
      + if $host then ["Host:      \($host_value)"] else [] end
      + if $intel then [
          "Intel proxy: \((.security.proxy // false) | btxt)",
          "Intel vpn:   \((.security.vpn // false) | btxt)",
          "Intel tor:   \((.security.tor // false) | btxt)",
          "Intel host:  \((.security.hosting // false) | btxt)",
          "Intel tipo:  \(.connection.type // "n/a")",
          "Intel score: \(risk)"
        ] else [] end
      + if $intel and $risk_visual then [
          "Intel nivel: \(risk_label)"
        ] else [] end
      + if $map then ["Mapa:      https://www.google.com/maps?q=\(.latitude),\(.longitude)"] else [] end
    )[]'
}

to_csv() {
  local ping_value="$1"
  local host_value="$2"
  jq -r --argjson map "$MAP_MODE" --argjson ping "$PING_MODE" --argjson host "$HOST_MODE" --argjson intel "$INTEL_MODE" --arg ping_value "$ping_value" --arg host_value "$host_value" '
    def b2i(v): if v == true then 1 else 0 end;
    def risk: ((b2i(.security.proxy // false) + b2i(.security.vpn // false) + b2i(.security.tor // false) + b2i(.security.hosting // false)) * 25);
    def risk_label:
      if risk >= 75 then "CRITICAL"
      elif risk >= 50 then "HIGH"
      elif risk >= 25 then "MED"
      else "LOW" end;
    [
      .ip,
      .country,
      .region,
      .city,
      .postal,
      (.latitude|tostring),
      (.longitude|tostring),
      .timezone.id,
      .connection.isp,
      (if .connection.org == "Google LLC" then "cyber" else .connection.org end),
      (if $map then ("https://www.google.com/maps?q=" + (.latitude|tostring) + "," + (.longitude|tostring)) else "" end),
      (if $ping then $ping_value else "" end),
      (if $host then $host_value else "" end),
      (if $intel then ((.security.proxy // false)|tostring) else "" end),
      (if $intel then ((.security.vpn // false)|tostring) else "" end),
      (if $intel then ((.security.tor // false)|tostring) else "" end),
      (if $intel then ((.security.hosting // false)|tostring) else "" end),
      (if $intel then (.connection.type // "n/a") else "" end),
      (if $intel then (risk|tostring) else "" end),
      (if $intel then risk_label else "" end)
    ] | @csv
  '
}

process_single() {
  local ip="$1"
  local resp success msg ping_value host_value

  if ! validate_ip "$ip"; then
    err "IP invalido: '$ip'"
    return 1
  fi

  if [[ "$(is_private_ip "$ip")" == "1" ]]; then
    local faixa iface prefix
    faixa="$(private_range_label "$ip")"
    IFS=$'\t' read -r iface prefix <<<"$(get_private_meta "$ip")"
    if [[ $JSON_MODE -eq 1 ]]; then
      private_to_json "$ip" "$faixa" "$iface" "$prefix"
    elif [[ "$EXPORT_FORMAT" == "csv" ]]; then
      private_to_csv "$ip" "$faixa"
    else
      private_to_text "$ip" "$faixa" "$iface" "$prefix"
    fi
    return 0
  fi

  resp="$(query_ip "$ip")"
  success="$(jq -r '.success // false' <<<"$resp")"
  if [[ "$success" != "true" ]]; then
    msg="$(jq -r '.message // "erro desconhecido"' <<<"$resp")"
    err "Nao foi possivel localizar o IP '$ip': $msg"
    return 1
  fi

  ping_value=""
  host_value=""
  [[ $PING_MODE -eq 1 ]] && ping_value="$(get_ping_ms "$ip")"
  [[ $HOST_MODE -eq 1 ]] && host_value="$(get_reverse_host "$ip")"
  [[ $ANOMALY_MODE -eq 1 ]] && check_and_record_anomaly "$ip" "$resp"
  [[ $SCREENSHOT_MAP_MODE -eq 1 ]] && save_map_screenshot_from_resp "$ip" "$resp" || true

  if [[ $JSON_MODE -eq 1 ]]; then
    to_compact_json "$ping_value" "$host_value" <<<"$resp"
  elif [[ "$EXPORT_FORMAT" == "csv" ]]; then
    to_csv "$ping_value" "$host_value" <<<"$resp"
  else
    to_text "$ping_value" "$host_value" <<<"$resp"
  fi
}

print_header() {
  [[ $JSON_MODE -eq 1 || "$EXPORT_FORMAT" == "csv" ]] && return 0
  print_banner
  type_line "${C_BOLD}${C_GREEN_NEON}${NOME_FERRAMENTA} v${VERSAO} - por ${AUTOR}${C_RESET}"
  [[ -n "$IP" && $MEU_IP_MODE -eq 0 ]] && type_line "${C_GREEN_DARK}Consultando localizacao para o IP: ${IP}${C_RESET}"
  [[ $MEU_IP_MODE -eq 1 ]] && type_line "${C_GREEN_DARK}Consultando localizacao para o seu IP publico: ${IP}${C_RESET}"
  [[ $MEU_IP_PRIVADO_MODE -eq 1 ]] && type_line "${C_GREEN_DARK}Consultando IP(s) privado(s) local(is)${C_RESET}"
  [[ -n "$BATCH_FILE" ]] && type_line "${C_GREEN_DARK}Consultando localizacao em lote: ${BATCH_FILE}${C_RESET}"
  print_divider
}

print_footer() {
  [[ $JSON_MODE -eq 1 || "$EXPORT_FORMAT" == "csv" ]] && return 0
  print_divider
  ok "assinatura: ${AUTOR}"
}

if [[ -z "$IP" && -z "$BATCH_FILE" && $MEU_IP_MODE -eq 0 && $MEU_IP_PRIVADO_MODE -eq 0 ]]; then
  print_help
  exit 1
fi

modo_count=0
[[ -n "$IP" ]] && modo_count=$((modo_count + 1))
[[ -n "$BATCH_FILE" ]] && modo_count=$((modo_count + 1))
[[ $MEU_IP_MODE -eq 1 ]] && modo_count=$((modo_count + 1))
[[ $MEU_IP_PRIVADO_MODE -eq 1 ]] && modo_count=$((modo_count + 1))
if [[ $modo_count -ne 1 ]]; then
  err "Use apenas um modo: <ip> ou --batch <arquivo> ou --meu-ip ou --meu-ip-privado."
  exit 1
fi

OUTPUT=""

if [[ $MEU_IP_MODE -eq 1 ]]; then
  IP="$(get_meu_ip)"
  if [[ -z "$IP" ]]; then
    err "Nao foi possivel detectar seu IP publico."
    exit 1
  fi
fi

if [[ $MEU_IP_PRIVADO_MODE -eq 1 ]]; then
  PRIVATE_IPS_LIST="$(get_private_ips_list)"
  if [[ -z "$PRIVATE_IPS_LIST" ]]; then
    err "Nao foi possivel detectar IP privado local."
    exit 1
  fi
fi

print_header

if [[ $MEU_IP_PRIVADO_MODE -eq 1 ]]; then
  if [[ $JSON_MODE -eq 1 ]]; then
    TMP_JSON="$(mktemp)"
    while IFS=$'\t' read -r p_ip p_prefix p_iface; do
      [[ -z "$p_ip" ]] && continue
      faixa="$(private_range_label "$p_ip")"
      printf "%s\n" "$(private_to_json "$p_ip" "$faixa" "$p_iface" "$p_prefix")" >>"$TMP_JSON"
    done <<<"$PRIVATE_IPS_LIST"
    OUTPUT="$(jq -s '.' "$TMP_JSON")"
    rm -f "$TMP_JSON"
  elif [[ "$EXPORT_FORMAT" == "csv" ]]; then
    CSV_HEADER='"ip","pais","regiao","cidade","cep","latitude","longitude","fuso","isp","organizacao","mapa_url","ping_ms","host_reverso","intel_proxy","intel_vpn","intel_tor","intel_hosting","intel_tipo_conexao","intel_risk_score","intel_risk_level"'
    LINES=()
    while IFS=$'\t' read -r p_ip _ _; do
      [[ -z "$p_ip" ]] && continue
      faixa="$(private_range_label "$p_ip")"
      LINES+=("$(private_to_csv "$p_ip" "$faixa")")
    done <<<"$PRIVATE_IPS_LIST"
    OUTPUT="${CSV_HEADER}"
    if [[ ${#LINES[@]} -gt 0 ]]; then
      OUTPUT+=$'\n'"$(printf '%s\n' "${LINES[@]}")"
      OUTPUT="${OUTPUT%$'\n'}"
    fi
  else
    BLOCKS=()
    while IFS=$'\t' read -r p_ip p_prefix p_iface; do
      [[ -z "$p_ip" ]] && continue
      faixa="$(private_range_label "$p_ip")"
      BLOCKS+=("$(private_to_text "$p_ip" "$faixa" "$p_iface" "$p_prefix")")
    done <<<"$PRIVATE_IPS_LIST"
    OUTPUT="$(printf '%s\n--------------------------\n' "${BLOCKS[@]}")"
    OUTPUT="${OUTPUT%$'\n--------------------------\n'}"
  fi
  append_history "private" "local"
elif [[ -n "$IP" ]]; then
  if ! OUTPUT="$(process_single "$IP")"; then
    exit 1
  fi
  if [[ "$EXPORT_FORMAT" == "csv" ]]; then
    CSV_HEADER='"ip","pais","regiao","cidade","cep","latitude","longitude","fuso","isp","organizacao","mapa_url","ping_ms","host_reverso","intel_proxy","intel_vpn","intel_tor","intel_hosting","intel_tipo_conexao","intel_risk_score","intel_risk_level"'
    OUTPUT="${CSV_HEADER}"$'\n'"${OUTPUT}"
  fi
  append_history "single" "$IP"
else
  if [[ ! -f "$BATCH_FILE" ]]; then
    err "Arquivo de lote nao encontrado: $BATCH_FILE"
    exit 1
  fi
  BATCH_TOTAL="$(count_batch_ips "$BATCH_FILE")"
  BATCH_DONE=0

  if [[ $JSON_MODE -eq 1 ]]; then
    TMP_JSON="$(mktemp)"
    while IFS= read -r line || [[ -n "$line" ]]; do
      ip_line="$(echo "$line" | xargs)"
      [[ -z "$ip_line" || "$ip_line" == \#* ]] && continue
      BATCH_DONE=$((BATCH_DONE + 1))
      render_progress "$BATCH_DONE" "$BATCH_TOTAL" "json"

      if one="$(process_single "$ip_line" 2>/dev/null)"; then
        printf "%s\n" "$one" >>"$TMP_JSON"
      else
        jq -nc --arg ip "$ip_line" --arg erro "falha na consulta" '{ip:$ip, erro:$erro}' >>"$TMP_JSON"
      fi
    done <"$BATCH_FILE"

    OUTPUT="$(jq -s '.' "$TMP_JSON")"
    rm -f "$TMP_JSON"
    append_history "batch_json" "$BATCH_FILE"
  elif [[ "$EXPORT_FORMAT" == "csv" ]]; then
    CSV_HEADER='"ip","pais","regiao","cidade","cep","latitude","longitude","fuso","isp","organizacao","mapa_url","ping_ms","host_reverso","intel_proxy","intel_vpn","intel_tor","intel_hosting","intel_tipo_conexao","intel_risk_score","intel_risk_level"'
    LINES=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      ip_line="$(echo "$line" | xargs)"
      [[ -z "$ip_line" || "$ip_line" == \#* ]] && continue
      BATCH_DONE=$((BATCH_DONE + 1))
      render_progress "$BATCH_DONE" "$BATCH_TOTAL" "csv"

      if one="$(process_single "$ip_line" 2>/dev/null)"; then
        LINES+=("$one")
      else
        # linha minima com erro nas colunas finais
        LINES+=("\"$ip_line\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"erro\",\"\"")
      fi
    done <"$BATCH_FILE"
    OUTPUT="${CSV_HEADER}"
    if [[ ${#LINES[@]} -gt 0 ]]; then
      OUTPUT+=$'\n'"$(printf '%s\n' "${LINES[@]}")"
      OUTPUT="${OUTPUT%$'\n'}"
    fi
    append_history "batch_csv" "$BATCH_FILE"
  else
    BLOCKS=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      ip_line="$(echo "$line" | xargs)"
      [[ -z "$ip_line" || "$ip_line" == \#* ]] && continue
      BATCH_DONE=$((BATCH_DONE + 1))
      render_progress "$BATCH_DONE" "$BATCH_TOTAL" "texto"

      if one="$(process_single "$ip_line" 2>/dev/null)"; then
        BLOCKS+=("IP consultado: $ip_line"$'\n'"$one")
      else
        BLOCKS+=("IP consultado: $ip_line"$'\n'"ERRO: falha na consulta")
      fi
    done <"$BATCH_FILE"

    OUTPUT="$(printf '%s\n--------------------------\n' "${BLOCKS[@]}")"
    OUTPUT="${OUTPUT%$'\n--------------------------\n'}"
    append_history "batch_text" "$BATCH_FILE"
  fi
fi

if [[ -n "$OUT_FILE" ]]; then
  printf "%s\n" "$OUTPUT" >"$OUT_FILE"
  ok "Saida salva em: $OUT_FILE"
fi

printf "%s\n" "$OUTPUT"

if [[ $REPORT_MODE -eq 1 ]]; then
  generate_report "$OUTPUT"
fi

if [[ $REPORT_HTML_MODE -eq 1 ]]; then
  generate_html_report "$OUTPUT"
fi

if [[ -n "$NOTIFY_URL" ]]; then
  send_notify "$OUTPUT"
fi

print_footer
