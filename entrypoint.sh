#!/bin/sh
 
set -e

ENABLE_IP_CHECKER="${ENABLE_IP_CHECKER:-false}"
ENABLE_GUI_CLOSE="${ENABLE_GUI_CLOSE:-false}"
GUI_WINDOW_NAME="${GUI_WINDOW_NAME:-UrNetwork}"
AUTO_RESTART_INTERVAL="${AUTO_RESTART_INTERVAL:-86400}"
API_URL="https://api.github.com/repos/urnetwork/build/releases/latest"
IP_CHECKER_URL="https://raw.githubusercontent.com/techroy23/IP-Checker/refs/heads/main/app.sh"
APP_DIR="/app"
VERSION_FILE="$APP_DIR/version.txt"
JWT_FILE="/root/.urnetwork/jwt"
TMP_DIR="/tmp/urn_update"
UPDATE_TIME="12:00"

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
    rm -f ~/.urnetwork/jwt
    echo ">>> An2Kin >>> Removed existing JWT (if any)"
    echo ">>> An2Kin >>> Sleeping 15s before obtaining new JWT..."
    sleep 15

    echo ">>> An2Kin >>> Obtaining new JWT…"
    "$APP_DIR/provider" auth --user_auth="$USER_AUTH" --password="$PASSWORD" -f \
    || { echo ">>> An2Kin >>> auth failed" >&2; exit 1; }

    sleep 5

    [ -s "$JWT_FILE" ] || { echo ">>> An2Kin >>> no JWT file after auth" >&2; exit 1; }
    echo ">>> An2Kin >>> obtained JWT"
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

main_provider(){
    failures=0
    while :; do
        ensure_app_dir
        echo ">>> An2Kin >>> Starting provider (attempt #$((failures+1)))"
        "$APP_DIR/provider" provide &
        PROVIDER_PID=$!
        
        # Đợi một chút để provider khởi động
        sleep 5
        
        # Đóng GUI nếu có và được bật
        if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
            close_gui_window "$GUI_WINDOW_NAME" 10
        fi
        
        # Đợi process kết thúc
        wait $PROVIDER_PID
        code=$?
        if [ "$code" -eq 0 ]; then
            echo ">>> An2Kin >>> provider exited cleanly."
            break
        fi
        failures=$((failures+1))
        echo ">>> An2Kin >>> provider crashed (#$failures; code=$code)"
        if [ "$failures" -ge 3 ]; then
            echo ">>> An2Kin >>> too many crashes; clearing JWT and reauthenticating"
            rm -f "$JWT_FILE"
            login
            failures=0
        fi
        echo ">>> An2Kin >>> Waiting 60s before retry"
        sleep 60
    done
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

# Hàm đóng cửa sổ GUI để giảm lag CPU
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

# Hàm đóng GUI sau khi login (giống như trong start (2).sh)
close_gui_after_login() {
  local WINDOW_NAME="${1:-$GUI_WINDOW_NAME}"
  local INITIAL_WAIT="${2:-10}"
  
  if [ "$ENABLE_GUI_CLOSE" != "true" ]; then
    return 0
  fi
  
  log " >>> An2Kin >>> Closing GUI after login process..."
  
  # Đợi GUI mở xong
  log " >>> An2Kin >>> Waiting for GUI to open..."
  sleep "$INITIAL_WAIT"
  
  # Đóng GUI đi (như lúc auto-login, để không lag)
  log " >>> An2Kin >>> Closing GUI..."
  close_gui_window "$WINDOW_NAME" 0
  
  log " >>> An2Kin >>> GUI closed after login (process running, GUI closed, RAM cleared)"
}

# Hàm restart provider và đóng GUI (giống như restart_wipter trong start (2).sh)
restart_provider() {
  log " >>> An2Kin >>> Restarting provider to clear memory..."
  
  # BƯỚC 1: Kill process provider
  log " >>> An2Kin >>> Killing provider process..."
  pkill -f "provider provide" 2>/dev/null || pkill -x provider 2>/dev/null || true
  
  sleep 5
  
  # BƯỚC 2: Start provider lại (GUI tự động mở nếu có)
  log " >>> An2Kin >>> Starting provider..."
  ensure_app_dir
  "$APP_DIR/provider" provide &
  
  # BƯỚC 3: Đợi GUI mở xong (nếu có)
  if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
    log " >>> An2Kin >>> Waiting for GUI to open..."
    sleep 10
    
    # BƯỚC 4: Đóng GUI đi (như lúc auto-login, để không lag)
    log " >>> An2Kin >>> Closing GUI..."
    close_gui_window "$GUI_WINDOW_NAME" 0
  fi
  
  log " >>> An2Kin >>> Provider restarted successfully (process running, GUI closed, RAM cleared)"
}

runner() {
    echo ">>> An2Kin >>> Script version: v10.30.2025"
    sh /app/ipinfo.sh
    check_ip
    if [ -f /var/lib/vnstat/vnstat.db ]; then
        echo ">>> An2Kin >>> vnStat DB already exists (SQLite backend)"
    elif [ -f /var/lib/vnstat/.config ]; then
        echo ">>> An2Kin >>> vnStat DB already exists (binary backend)"
    else
        echo ">>> An2Kin >>> Initializing vnStat database"
        vnstatd --initdb
    fi
    # Kill existing vnstatd processes to avoid duplicates
    if pgrep -x vnstatd >/dev/null 2>&1; then
        echo ">>> An2Kin >>> Killing existing vnstatd processes..."
        pkill -x vnstatd 2>/dev/null || true
        sleep 2
    fi
    # Start vnstatd daemon if not running
    if ! pgrep -x vnstatd >/dev/null 2>&1; then
        vnstatd -d --alwaysadd >/dev/null 2>&1
        echo ">>> An2Kin >>> vnstatd started"
    else
        echo ">>> An2Kin >>> vnstatd already running"
    fi
    httpd -f -p 8080 -h /app &
    echo ">>> An2Kin >>> HTTP server started on container port 8080"
    ensure_app_dir
    check_and_update
    check_proxy
    
    # Start provider lần đầu
    login
    
    # Start provider ở background
    ensure_app_dir
    echo ">>> An2Kin >>> Starting provider..."
    "$APP_DIR/provider" provide &
    PROVIDER_PID=$!
    
    # Đợi một chút để provider khởi động
    sleep 5
    
    # Đóng GUI sau khi start (nếu được bật)
    if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
        close_gui_after_login "$GUI_WINDOW_NAME" 10
    fi
    
    ################################################################################
    # AUTO-RESTART PROVIDER MỖI 24H (hoặc theo AUTO_RESTART_INTERVAL) - ĐÓNG GUI
    ################################################################################
    if [ "$AUTO_RESTART_INTERVAL" -gt 0 ]; then
        (
            while true; do
                sleep "$AUTO_RESTART_INTERVAL"  # Mặc định 24 hours (86400 seconds)
                restart_provider
            done
        ) &
        RESTART_PID=$!
        echo ">>> An2Kin >>> Auto-restart monitor started (PID: $RESTART_PID, interval: ${AUTO_RESTART_INTERVAL}s)"
    fi
    
    # Time watcher cho updates
    (
      while :; do
        NOW="$(TZ='Asia/Manila' date +%H:%M)"
        if [ "$NOW" = "$UPDATE_TIME" ]; then
            echo ">>> An2Kin >>> watcher: hit $UPDATE_TIME, updating"
            check_and_update
            if ! ps aux | grep -q '[p]rovider provide'; then
                echo ">>> An2Kin >>> provider not running; launching now"
                login
                ensure_app_dir
                "$APP_DIR/provider" provide &
                sleep 5
                if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
                    close_gui_window "$GUI_WINDOW_NAME" 10
                fi
            else
                echo ">>> An2Kin >>> provider already running; skipping restart"
            fi
            sleep 60
        fi
        sleep 30
      done
    ) &
    WATCHER_PID=$!
    echo ">>> An2Kin >>> Time‐watcher PID is $WATCHER_PID"
    
    # Keep container running by monitoring provider process
    failures=0
    while true; do
        if ! pgrep -f "provider provide" > /dev/null && ! pgrep -x provider > /dev/null; then
            failures=$((failures + 1))
            log " >>> An2Kin >>> Provider process died (failure #$failures), restarting..."
            
            # Nếu crash quá nhiều lần, re-authenticate
            if [ "$failures" -ge 3 ]; then
                log " >>> An2Kin >>> Too many crashes; clearing JWT and re-authenticating"
                rm -f "$JWT_FILE"
                login
                failures=0
            fi
            
            ensure_app_dir
            "$APP_DIR/provider" provide &
            
            # Wait a bit before attempting to close GUI
            sleep 10
            
            # Close GUI after restart (ignore errors if no window)
            if [ "$ENABLE_GUI_CLOSE" = "true" ]; then
                close_gui_window "$GUI_WINDOW_NAME" 0 || true
            fi
        else
            # Reset failure counter nếu process đang chạy tốt
            failures=0
        fi
        
        sleep 180  # Check every 180 seconds
    done
}

main() {
    runner
}

main "$@"
