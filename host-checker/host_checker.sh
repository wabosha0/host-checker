#!/bin/bash
set -u
COUNT=2
TIMEOUT=2
HOSTS_FILE=""
LOG_FILE=""
HOSTS=()
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
  echo "Usage: $0 [-f hosts_file] [-o log_file] [-c count] [-t timeout] [host1 host2 ...]"
  exit 1
}

while getopts "f:o:c:t:h" opt; do
  case "$opt" in
    f) HOSTS_FILE="$OPTARG" ;;
    o) LOG_FILE="$OPTARG" ;;
    c) COUNT="$OPTARG" ;;
    t) TIMEOUT="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "$HOSTS_FILE" ]; then
  if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: file '$HOSTS_FILE' not found." >&2
    exit 1
  fi
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    HOSTS+=("$line")
  done < "$HOSTS_FILE"
fi

HOSTS+=("$@")

if [ "${#HOSTS[@]}" -eq 0 ]; then
  echo "Error: no hosts given. Use -f FILE or pass hosts directly." >&2
  usage
fi

UP_COUNT=0
DOWN_COUNT=0

echo "Checking ${#HOSTS[@]} host(s)..."
echo "--------------------------------"

for HOST in "${HOSTS[@]}"; do
  if ping -c "$COUNT" -W "$TIMEOUT" "$HOST" > /dev/null 2>&1; then
    STATUS="UP"
    echo -e "${GREEN}[UP]${NC}   $HOST"
    ((UP_COUNT++))
  else
    STATUS="DOWN"
    echo -e "${RED}[DOWN]${NC} $HOST"
    ((DOWN_COUNT++))
  fi
  if [ -n "$LOG_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S')  $HOST  $STATUS" >> "$LOG_FILE"
  fi
done

echo "--------------------------------"
echo "Summary: $UP_COUNT up, $DOWN_COUNT down (out of ${#HOSTS[@]})"
if [ -n "$LOG_FILE" ]; then
  echo "Results saved to $LOG_FILE"
fi

if [ "$DOWN_COUNT" -gt 0 ]; then
  exit 1
else
  exit 0
fi
