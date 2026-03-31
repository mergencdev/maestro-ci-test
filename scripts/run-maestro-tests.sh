#!/usr/bin/env bash
##
# @file    run-maestro-tests.sh
# @appId   com.mergenc.maestro_ci_test
#
# @tags
#  - script
#  - local
#
# @description
#  Local ortamda Maestro UI testlerini tek komutla çalıştırır.
#  Emulator kontrolü, APK build, install ve test koşumunu yapar.
#
# @usage
#  ./scripts/run-maestro-tests.sh           # Tüm testleri koş
#  ./scripts/run-maestro-tests.sh login     # Sadece login testlerini koş
#
# @author    Mehmet Emin Ergenç
# @version   1.0.0
##

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ID="com.mergenc.maestro_ci_test"
APK_PATH="$PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
FLOWS_DIR="$PROJECT_DIR/.maestro/flows"
OUTPUT_DIR="$PROJECT_DIR/maestro-output"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

check_prerequisites() {
    if ! command -v maestro &>/dev/null; then
        log_error "Maestro CLI bulunamadı. Kurulum: curl -fsSL https://get.maestro.mobile.dev | bash"
        exit 1
    fi

    if ! command -v adb &>/dev/null; then
        log_error "ADB bulunamadı. Android SDK kurulu olmalı."
        exit 1
    fi

    local devices
    devices=$(adb devices | grep -c -E "emulator|device$" || true)
    if [[ "$devices" -lt 1 ]]; then
        log_error "Bağlı emulator/cihaz bulunamadı. Önce bir emulator başlatın."
        exit 1
    fi

    log_info "Emulator/cihaz bağlı. Devam ediliyor..."
}

build_apk() {
    log_info "Debug APK build ediliyor..."
    cd "$PROJECT_DIR"
    ./gradlew assembleDebug --no-daemon -q

    if [[ ! -f "$APK_PATH" ]]; then
        log_error "APK bulunamadı: $APK_PATH"
        exit 1
    fi
    log_info "APK hazır: $APK_PATH"
}

install_apk() {
    log_info "APK yükleniyor..."
    adb install -r -t "$APK_PATH"
    log_info "APK yüklendi."
}

run_tests() {
    local target="${1:-}"
    local test_path="$FLOWS_DIR"

    if [[ -n "$target" ]]; then
        local matched
        matched=$(find "$FLOWS_DIR" -name "*${target}*" -not -path "*/reusable/*" | head -1)
        if [[ -n "$matched" ]]; then
            test_path="$matched"
            log_info "Hedef flow: $test_path"
        else
            log_warn "'$target' ile eşleşen flow bulunamadı. Tüm testler koşulacak."
        fi
    fi

    mkdir -p "$OUTPUT_DIR"

    log_info "Maestro testleri başlatılıyor..."
    echo ""

    maestro test \
        --env EMAIL=test@maestro.dev \
        --env PASSWORD=Test1234! \
        --env TEST_USER="Maestro Test User" \
        --format junit \
        --output "$OUTPUT_DIR/results.xml" \
        --debug-output "$OUTPUT_DIR/debug" \
        "$test_path"

    local exit_code=$?

    echo ""
    if [[ $exit_code -eq 0 ]]; then
        log_info "Tüm testler başarılı!"
    else
        log_error "Bazı testler başarısız oldu. Detaylar: $OUTPUT_DIR/"
    fi

    log_info "JUnit raporu: $OUTPUT_DIR/results.xml"
    log_info "Debug çıktıları: $OUTPUT_DIR/debug/"

    return $exit_code
}

main() {
    log_info "=== Maestro UI Test Runner ==="
    echo ""

    check_prerequisites
    build_apk
    install_apk
    run_tests "${1:-}"
}

main "$@"
