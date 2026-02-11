#!/usr/bin/env bash
set -euo pipefail

NOME_FERRAMENTA="ipx br"
VERSAO="1.0.0"
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
IP=""
NO_COLOR=0
MEU_IP_MODE=0
MAP_MODE=0

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_CYAN=$'\033[36m'
  C_GREEN=$'\033[32m'
  C_RED=$'\033[31m'
  C_YELLOW=$'\033[33m'
else
  C_RESET=""
  C_CYAN=""
  C_GREEN=""
  C_RED=""
  C_YELLOW=""
fi

run_numeric_menu() {
  echo "$BANNER"
  echo "${NOME_FERRAMENTA} v${VERSAO} - por ${AUTOR}"
  echo
  echo "Escolha uma opcao:"
  echo "  1) Consultar um IP"
  echo "  2) Consultar meu IP publico (com mapa)"
  echo "  3) Consultar um IP com mapa"
  echo "  4) Consulta em lote por arquivo"
  echo "  5) Mostrar ajuda"
  echo "  0) Sair"
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
      set -- --help
      ;;
    0)
      exit 0
      ;;
    *)
      echo "Opcao invalida."
      exit 1
      ;;
  esac

  if [[ "$1" != "--help" ]]; then
    read -r -p "Saida em JSON? (s/N): " m_json
    if [[ "$m_json" =~ ^[sS]$ ]]; then
      set -- --json "$@"
    fi

    read -r -p "Salvar em arquivo? (s/N): " m_out
    if [[ "$m_out" =~ ^[sS]$ ]]; then
      read -r -p "Nome do arquivo de saida: " m_out_file
      if [[ -n "$m_out_file" ]]; then
        set -- --out "$m_out_file" "$@"
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
  echo "  --map               Mostra link do Google Maps"
  echo "  --no-color          Desativa cores no terminal"
  echo
  echo "Exemplos:"
  echo "  $0 8.8.8.8"
  echo "  $0 --json 1.1.1.1"
  echo "  $0 --batch ips.txt --out resultado.txt"
  echo "  $0 --meu-ip --map"
  echo "  $0 1              # abre fluxo numerico"
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
      set -- --help
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
    --map)
      MAP_MODE=1
      shift
      ;;
    --no-color)
      NO_COLOR=1
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

if [[ $NO_COLOR -eq 1 ]]; then
  C_RESET=""; C_CYAN=""; C_GREEN=""; C_RED=""; C_YELLOW=""
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

validate_ip() {
  local ip="$1"
  python3 - "$ip" >/dev/null 2>&1 <<'PY'
import ipaddress
import sys
ipaddress.ip_address(sys.argv[1])
PY
}

query_ip() {
  local ip="$1"
  local url="https://ipwho.is/${ip}"
  curl -sS "$url"
}

get_meu_ip() {
  curl -sS "https://api.ipify.org?format=json" | jq -r '.ip // empty'
}

to_compact_json() {
  jq -c --argjson map "$MAP_MODE" '
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
    } + if $map then {mapa_url: ("https://www.google.com/maps?q=" + (.latitude|tostring) + "," + (.longitude|tostring))} else {} end)
  '
}

to_text() {
  jq -r --argjson map "$MAP_MODE" '
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
    ] + if $map then ["Mapa:      https://www.google.com/maps?q=\(.latitude),\(.longitude)"] else [] end)[]'
}

process_single() {
  local ip="$1"
  local resp success msg

  if ! validate_ip "$ip"; then
    err "IP invalido: '$ip'"
    return 1
  fi

  resp="$(query_ip "$ip")"
  success="$(jq -r '.success // false' <<<"$resp")"
  if [[ "$success" != "true" ]]; then
    msg="$(jq -r '.message // "erro desconhecido"' <<<"$resp")"
    err "Nao foi possivel localizar o IP '$ip': $msg"
    return 1
  fi

  if [[ $JSON_MODE -eq 1 ]]; then
    to_compact_json <<<"$resp"
  else
    to_text <<<"$resp"
  fi
}

print_header() {
  [[ $JSON_MODE -eq 1 ]] && return 0
  echo "$BANNER"
  info "${NOME_FERRAMENTA} v${VERSAO} - por ${AUTOR}"
  [[ -n "$IP" && $MEU_IP_MODE -eq 0 ]] && info "Consultando localizacao para o IP: ${IP}"
  [[ $MEU_IP_MODE -eq 1 ]] && info "Consultando localizacao para o seu IP publico: ${IP}"
  [[ -n "$BATCH_FILE" ]] && info "Consultando localizacao em lote: ${BATCH_FILE}"
  echo
}

print_footer() {
  [[ $JSON_MODE -eq 1 ]] && return 0
  echo
  ok "assinatura: ${AUTOR}"
}

if [[ -z "$IP" && -z "$BATCH_FILE" && $MEU_IP_MODE -eq 0 ]]; then
  print_help
  exit 1
fi

modo_count=0
[[ -n "$IP" ]] && modo_count=$((modo_count + 1))
[[ -n "$BATCH_FILE" ]] && modo_count=$((modo_count + 1))
[[ $MEU_IP_MODE -eq 1 ]] && modo_count=$((modo_count + 1))
if [[ $modo_count -ne 1 ]]; then
  err "Use apenas um modo: <ip> ou --batch <arquivo> ou --meu-ip."
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

print_header

if [[ -n "$IP" ]]; then
  if ! OUTPUT="$(process_single "$IP")"; then
    exit 1
  fi
else
  if [[ ! -f "$BATCH_FILE" ]]; then
    err "Arquivo de lote nao encontrado: $BATCH_FILE"
    exit 1
  fi

  if [[ $JSON_MODE -eq 1 ]]; then
    TMP_JSON="$(mktemp)"
    while IFS= read -r line || [[ -n "$line" ]]; do
      ip_line="$(echo "$line" | xargs)"
      [[ -z "$ip_line" || "$ip_line" == \#* ]] && continue

      if validate_ip "$ip_line"; then
        resp="$(query_ip "$ip_line")"
        success="$(jq -r '.success // false' <<<"$resp")"
        if [[ "$success" == "true" ]]; then
          to_compact_json <<<"$resp" >>"$TMP_JSON"
        else
          msg="$(jq -r '.message // "erro desconhecido"' <<<"$resp")"
          jq -nc --arg ip "$ip_line" --arg erro "$msg" '{ip:$ip, erro:$erro}' >>"$TMP_JSON"
        fi
      else
        jq -nc --arg ip "$ip_line" --arg erro "IP invalido" '{ip:$ip, erro:$erro}' >>"$TMP_JSON"
      fi
    done <"$BATCH_FILE"

    OUTPUT="$(jq -s '.' "$TMP_JSON")"
    rm -f "$TMP_JSON"
  else
    BLOCKS=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      ip_line="$(echo "$line" | xargs)"
      [[ -z "$ip_line" || "$ip_line" == \#* ]] && continue

      if one="$(process_single "$ip_line" 2>/dev/null)"; then
        BLOCKS+=("IP consultado: $ip_line"$'\n'"$one")
      else
        BLOCKS+=("IP consultado: $ip_line"$'\n'"ERRO: falha na consulta")
      fi
    done <"$BATCH_FILE"

    OUTPUT="$(printf '%s\n--------------------------\n' "${BLOCKS[@]}")"
    OUTPUT="${OUTPUT%$'\n--------------------------\n'}"
  fi
fi

if [[ -n "$OUT_FILE" ]]; then
  printf "%s\n" "$OUTPUT" >"$OUT_FILE"
  ok "Saida salva em: $OUT_FILE"
fi

printf "%s\n" "$OUTPUT"
print_footer
