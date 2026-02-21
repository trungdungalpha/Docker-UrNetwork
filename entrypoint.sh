#!/bin/sh
 
set -e

ENABLE_IP_CHECKER="${ENABLE_IP_CHECKER:-false}"
ENABLE_GUI_CLOSE="${ENABLE_GUI_CLOSE:-false}"
GUI_WINDOW_NAME="${GUI_WINDOW_NAME:-UrNetwork}"
API_URL="https://api.github.com/repos/urnetwork/build/releases/latest"
IP_CHECKER_URL="https://raw.githubusercontent.com/techroy23/IP-Checker/refs/heads/main/app.sh"
APP_DIR="/app"
VERSION_FILE="$APP_DIR/version.txt"
JWT_FILE="/root/.urnetwork/jwt"
TMP_DIR="/tmp/urn_update"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

ensure_app_dir() {
    [ -d "$APP_DIR" ] || {
        echo ">>> An2Kin >>> Error: APP_DIR '$APP_DIR' does not exist." >&2
        exit 1
    }
    cd "$APP_DIR" || {
        echo ">>> An2Kin >>> Error: cannot cd to '$APP_DIR'." >&2
        exit 1
    }
}

get_arch() {
    case "$(uname -m)" in
      x86_64)  URN_ARCH=amd64  ;;
      aarch64) URN_ARCH=arm64  ;;
      *)
        echo ">>> An2Kin >>> Unsupported arch $(uname -m)" >&2
        exit 1
        ;;
    esac
}

check_and_update() {
    get_arch
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION="$(cat "$VERSION_FILE")"
    else
        CURRENT_VERSION=""
    fi
    echo ">>> An2Kin >>> Current provider version: ${CURRENT_VERSION:-none}"
    mkdir -p "$TMP_DIR"
    RESP_FILE="$TMP_DIR/release.json"
    HTTP_CODE="$(curl -sL -w '%{http_code}' -o "$RESP_FILE" "$API_URL")"
    RELEASE_JSON="$(cat "$RESP_FILE")"
    DOWNLOAD_URL="$(printf '%s\n' "$RELEASE_JSON" \
      | grep '"browser_download_url"' \
      | grep '\.tar\.gz' \
      | sed -E 's/.*"([^"]+)".*/\1/' \
      | head -n1)"
    [ -n "$DOWNLOAD_URL" ] || {
        echo ">>> An2Kin >>> No .tar.gz URL in GitHub response." >&2
        echo ">>> An2Kin >>> HTTP status: $HTTP_CODE" >&2
        echo ">>> An2Kin >>> Raw response:" >&2
        echo "$RELEASE_JSON" | jq . >&2
        return 0
    }

    LATEST_VERSION="$(printf '%s\n' "$DOWNLOAD_URL" \
      | sed -E 's#.*/download/v([^/]+)/.*#\1#')"
    echo ">>> An2Kin >>> Latest provider version: $LATEST_VERSION"
    if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
        echo ">>> An2Kin >>> Already at latest provider version; skipping."
        return 0
    else
        echo ">>> An2Kin >>> Updating provider from ( $CURRENT_VERSION ) → ( $LATEST_VERSION )"
        pkill -x provider 2>/dev/null || echo ">>> An2Kin >>> No provider to kill"
        mkdir -p "$TMP_DIR"
        ARCHIVE="$TMP_DIR/urnetwork-provider_${LATEST_VERSION}.tar.gz"
        curl -sL "$DOWNLOAD_URL" -o "$ARCHIVE"
        tar -xzf "$ARCHIVE" -C "$TMP_DIR" "linux/$URN_ARCH/provider" > /dev/null 2>&1
        mv "$TMP_DIR/linux/$URN_ARCH/provider" "$APP_DIR/provider"
        echo "$LATEST_VERSION" > "$VERSION_FILE"
        echo ">>> An2Kin >>> Update provider complete"
    fi
}

login() {
    # Priority 1: AUTH_CODE (auth token) - avoids 503 errors
    if [ -n "$AUTH_CODE" ]; then
        echo ">>> An2Kin >>> Using AUTH_CODE for authentication..."
        rm -f ~/.urnetwork/jwt
        echo ">>> An2Kin >>> Removed existing JWT (if any)"

        # Retry loop for auth code
        while true; do
            echo ">>> An2Kin >>> Attempting auth with auth code..."
            if "$APP_DIR/provider" auth "$AUTH_CODE" -f; then
                echo ">>> An2Kin >>> Auth code authentication successful"
                return 0
            else
                echo ">>> An2Kin >>> auth failed, retrying in 60s..." >&2
                sleep 60
            fi
        done

    # Priority 2: USER_AUTH/PASSWORD fallback (may get 503 errors)
    elif [ -n "$USER_AUTH" ] && [ -n "$PASSWORD" ]; then
        echo ">>> An2Kin >>> WARNING: Using USER_AUTH/PASSWORD login (may get 503 errors)"
        rm -f ~/.urnetwork/jwt
        echo ">>> An2Kin >>> Removed existing JWT (if any)"

        echo ">>> An2Kin >>> Obtaining new JWT…"
        "$APP_DIR/provider" auth --user_auth="$USER_AUTH" --password="$PASSWORD" -f \
        || { echo ">>> An2Kin >>> auth failed" >&2; exit 1; }

        [ -s "$JWT_FILE" ] || { echo ">>> An2Kin >>> no JWT file after auth" >&2; exit 1; }
        echo ">>> An2Kin >>> obtained JWT"

    # No credentials provided
    else
        echo ">>> An2Kin >>> ERROR: No AUTH_CODE or USER_AUTH/PASSWORD provided" >&2
        echo ">>> An2Kin >>> Please set -e AUTH_CODE=<your_auth_code> or -e USER_AUTH=<email> -e PASSWORD=<pass>" >&2
        exit 1
    fi
}

check_proxy() {
    echo ">>> An2Kin >>> Checking proxy configuration"
    ls -la ~/.urnetwork/ 2>/dev/null || echo ">>> An2Kin >>> ~/.urnetwork/ not found"
    rm -f ~/.urnetwork/proxy
    if [ -f "/app/proxy.txt" ]; then
        echo ">>> An2Kin >>> proxy.txt found; adding proxy"
        "$APP_DIR/provider" proxy add --proxy_file="/app/proxy.txt"
    else
        echo ">>> An2Kin >>> No proxy.txt found; skipping proxy add"
    fi
}

check_ip() {
  if [ "$ENABLE_IP_CHECKER" = "true" ]; then
    log " >>> An2Kin >>> Checking current public IP..."
    if curl -fsSL "$IP_CHECKER_URL" | sh; then
      log " >>> An2Kin >>> IP checker script ran successfully"
    else
      log " >>> An2Kin >>> WARNING: Could not fetch or execute IP checker script"
    fi
  else
    log " >>> An2Kin >>> IP checker disabled (ENABLE_IP_CHECKER=$ENABLE_IP_CHECKER)"
  fi
}

# Hàm đóng cửa sổ GUI để giảm CPU usage
close_gui_window() {
  local WINDOW_NAME="${1:-$GUI_WINDOW_NAME}"
  local WAIT_TIME="${2:-10}"
  
  if [ "$ENABLE_GUI_CLOSE" != "true" ]; then
    return 0
  fi
  
  log " >>> An2Kin >>> Closing GUI window: $WINDOW_NAME"
  
  # Kiểm tra xem xdotool có sẵn không
  if ! command -v xdotool >/dev/null 2>&1; then
    log " >>> An2Kin >>> Warning: xdotool is not installed. Skipping GUI close."
    return 1
  fi
  
  # Kiểm tra xem DISPLAY có được set không
  if [ -z "$DISPLAY" ]; then
    log " >>> An2Kin >>> Warning: DISPLAY environment variable is not set. Skipping GUI close."
    return 1
  fi
  
  # Đợi một chút để đảm bảo cửa sổ đã mở
  sleep "$WAIT_TIME"
  
  # Tìm và đóng cửa sổ
  WINDOW_ID=$(xdotool search --name "$WINDOW_NAME" 2>/dev/null | tail -n1)
  
  if [ -n "$WINDOW_ID" ]; then
    log " >>> An2Kin >>> Found window with ID: $WINDOW_ID"
    xdotool windowfocus "$WINDOW_ID" 2>/dev/null || true
    sleep 2
    xdotool windowclose "$WINDOW_ID" 2>/dev/null || true
    log " >>> An2Kin >>> GUI window '$WINDOW_NAME' closed successfully"
    return 0
  else
    log " >>> An2Kin >>> Warning: No window named '$WINDOW_NAME' found to close"
    return 1
  fi
}

runner() {
    echo ">>> An2Kin >>> Script version: v10.30.2025"
    sh /app/ipinfo.sh
    check_ip
    # vnstatd disabled to reduce CPU usage
    # Uncomment below if you need network statistics (stats portal)
    # if [ -f /var/lib/vnstat/vnstat.db ]; then
    #     echo ">>> An2Kin >>> vnStat DB already exists (SQLite backend)"
    # elif [ -f /var/lib/vnstat/.config ]; then
    #     echo ">>> An2Kin >>> vnStat DB already exists (binary backend)"
    # else
    #     echo ">>> An2Kin >>> Initializing vnStat database"
    #     vnstatd --initdb
    # fi
    # # Kill existing vnstatd processes to avoid duplicates
    # if pgrep -x vnstatd >/dev/null 2>&1; then
    #     echo ">>> An2Kin >>> Killing existing vnstatd processes..."
    #     pkill -x vnstatd 2>/dev/null || true
    #     sleep 2
    # fi
    # # Start vnstatd daemon if not running
    # if ! pgrep -x vnstatd >/dev/null 2>&1; then
    #     vnstatd -d --alwaysadd >/dev/null 2>&1
    #     echo ">>> An2Kin >>> vnstatd started"
    # else
    #     echo ">>> An2Kin >>> vnstatd already running"
    # fi
    # httpd -f -p 8080 -h /app &
    # echo ">>> An2Kin >>> HTTP server started on container port 8080"
    echo ">>> An2Kin >>> vnstatd and HTTP stats server disabled (CPU optimization)"
    ensure_app_dir
    check_proxy
    
    # Start provider
    login
    
    # Start provider ở background
    ensure_app_dir
    echo ">>> An2Kin >>> Starting provider..."
    "$APP_DIR/provider" provide &
    PROVIDER_PID=$!
    
    # Đợi một chút để provider khởi động và GUI mở (nếu có)
    sleep 10
    
    # Đóng GUI nếu được bật (để giảm CPU usage)
    if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
        close_gui_window "$GUI_WINDOW_NAME" 0
    fi
    
    # Chờ provider process (giữ container running)
    wait $PROVIDER_PID
}

main() {
    runner
}

main "$@"
