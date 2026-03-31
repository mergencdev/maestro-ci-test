#!/usr/bin/env bash
##
# @file    push-and-test.sh
# @appId   com.mergenc.maestro_ci_test
#
# @description
#  Local değişiklikleri commit edip main'e push eder,
#  ardından GitHub Actions workflow'unu takip ederek
#  test sonuçlarını terminalde gösterir.
#
# @usage
#  ./scripts/push-and-test.sh "feat: login ekranı güncellendi"
#  ./scripts/push-and-test.sh   # (commit mesajı interaktif sorulur)
#
# @author    Mehmet Emin Ergenç
# @version   1.0.0
##

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "${CYAN}[STEP]${NC}  ${BOLD}$*${NC}"; }

check_gh_cli() {
    if ! command -v gh &>/dev/null; then
        log_error "GitHub CLI (gh) bulunamadı."
        log_error "Kurulum: brew install gh && gh auth login"
        exit 1
    fi

    if ! gh auth status &>/dev/null 2>&1; then
        log_error "GitHub CLI authenticate değil. Çalıştır: gh auth login"
        exit 1
    fi
}

push_changes() {
    local msg="${1:-}"

    if [[ -z $(git status --porcelain) ]]; then
        log_warn "Commit edilecek değişiklik yok. Sadece son push'un workflow'u takip edilecek."
        return 0
    fi

    if [[ -z "$msg" ]]; then
        echo -e "${CYAN}Commit mesajı:${NC} "
        read -r msg
        if [[ -z "$msg" ]]; then
            msg="test: maestro flow güncellendi"
        fi
    fi

    log_step "Değişiklikler commit ediliyor..."
    git add -A
    git commit -m "$msg"

    log_step "main branch'e push ediliyor..."
    git push origin main
}

watch_workflow() {
    log_step "GitHub Actions workflow başlatılması bekleniyor..."
    sleep 5

    local run_id=""
    local attempts=0

    while [[ -z "$run_id" && $attempts -lt 12 ]]; do
        run_id=$(gh run list --workflow=maestro.yml --branch=main --limit=1 --json databaseId,status --jq '.[0].databaseId' 2>/dev/null || true)
        if [[ -z "$run_id" ]]; then
            attempts=$((attempts + 1))
            log_warn "Workflow henüz başlamadı, bekleniyor... ($attempts/12)"
            sleep 5
        fi
    done

    if [[ -z "$run_id" ]]; then
        log_error "Workflow bulunamadı. GitHub Actions'ı manuel kontrol edin."
        exit 1
    fi

    local run_url
    run_url=$(gh run view "$run_id" --json url --jq '.url')
    log_info "Workflow başladı: $run_url"

    echo ""
    log_step "Test koşumu takip ediliyor (canlı)..."
    echo ""

    gh run watch "$run_id" --exit-status 2>&1 || true

    echo ""
    echo "========================================="

    local conclusion
    conclusion=$(gh run view "$run_id" --json conclusion --jq '.conclusion')

    if [[ "$conclusion" == "success" ]]; then
        echo -e "${GREEN}${BOLD}  TESTLER BAŞARILI${NC}"
    else
        echo -e "${RED}${BOLD}  TESTLER BAŞARISIZ${NC}"
    fi

    echo "========================================="
    echo ""

    log_step "Test detayları:"
    gh run view "$run_id" --json jobs --jq '.jobs[] | "  \(.name): \(.conclusion) (\(.steps | map(select(.conclusion != "success" and .conclusion != "skipped")) | map(.name) | join(", ")))"'

    echo ""
    log_info "Detaylı rapor: $run_url"

    if [[ "$conclusion" == "failure" ]]; then
        echo ""
        log_step "Başarısız adımların logları:"
        gh run view "$run_id" --log-failed 2>&1 | tail -40

        echo ""
        log_info "Debug artifact indirmek için:"
        echo "  gh run download $run_id -n maestro-test-results -D maestro-output"
    fi

    [[ "$conclusion" == "success" ]]
}

main() {
    log_info "=== Push & Test Workflow ==="
    echo ""

    check_gh_cli
    push_changes "${1:-}"
    watch_workflow
}

main "$@"
