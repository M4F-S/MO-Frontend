#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# optimize-performance.sh
# Automated performance audit script.
# Accepts a URL as argument, runs Lighthouse or curl-based checks,
# and outputs a pass/fail report for core metrics.
# =============================================================================

SCRIPT_NAME="$(basename "$0")"
TARGET_URL="${1:-}"
REPORT_DIR="performance-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/report_${TIMESTAMP}.md"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

pass() { echo -e "${GREEN}PASS${NC} - $1"; }
fail() { echo -e "${RED}FAIL${NC} - $1"; }
warn() { echo -e "${YELLOW}WARN${NC} - $1"; }
info() { echo -e "${BLUE}INFO${NC} - $1"; }

log_result() {
  local status="$1"
  local message="$2"
  echo "$status - $message" >> "$REPORT_FILE"
}

# ---------------------------------------------------------------------------
# Validate input
# ---------------------------------------------------------------------------

if [ -z "$TARGET_URL" ]; then
  echo "Usage: $SCRIPT_NAME <url>"
  echo "Example: $SCRIPT_NAME https://example.com"
  exit 1
fi

# Validate URL format (basic)
if ! [[ "$TARGET_URL" =~ ^https?:// ]]; then
  echo "Error: URL must start with http:// or https://"
  exit 1
fi

# Create report directory
mkdir -p "$REPORT_DIR"

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------

cat > "$REPORT_FILE" << HEADER
# Performance Audit Report

**URL:** $TARGET_URL  
**Date:** $(date -Iseconds)  
**Auditor:** $SCRIPT_NAME

---

HEADER

echo ""
echo "========================================"
echo "  Performance Audit: $TARGET_URL"
echo "========================================"
echo ""

# ---------------------------------------------------------------------------
# 1. Lighthouse Audit (if available)
# ---------------------------------------------------------------------------

LIGHTHOUSE_AVAILABLE=false
LIGHTHOUSE_JSON=""

if command -v npx &>/dev/null && npx lighthouse --version &>/dev/null; then
  LIGHTHOUSE_AVAILABLE=true
  info "Lighthouse detected. Running full audit..."
  echo ""

  LIGHTHOUSE_JSON="$REPORT_DIR/lighthouse_${TIMESTAMP}.json"
  npx lighthouse "$TARGET_URL" \
    --output=json \
    --output-path="$LIGHTHOUSE_JSON" \
    --chrome-flags="--headless --no-sandbox --disable-gpu" \
    --only-categories=performance \
    --quiet 2>/dev/null || {
    warn "Lighthouse audit failed. Falling back to curl-based checks."
    LIGHTHOUSE_AVAILABLE=false
    LIGHTHOUSE_JSON=""
  }
else
  warn "Lighthouse not available. Using curl-based heuristic checks."
fi

# ---------------------------------------------------------------------------
# 2. Extract metrics from Lighthouse (if available)
# ---------------------------------------------------------------------------

LCP_VAL=""
CLS_VAL=""
FCP_VAL=""
SI_VAL=""
TBT_VAL=""

if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ -f "$LIGHTHOUSE_JSON" ]; then
  LCP_VAL=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    const lcp = data.audits['largest-contentful-paint'];
    console.log(lcp ? lcp.numericValue.toFixed(0) : 'N/A');
  " 2>/dev/null || echo "N/A")

  CLS_VAL=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    const cls = data.audits['cumulative-layout-shift'];
    console.log(cls ? cls.numericValue.toFixed(3) : 'N/A');
  " 2>/dev/null || echo "N/A")

  FCP_VAL=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    const fcp = data.audits['first-contentful-paint'];
    console.log(fcp ? fcp.numericValue.toFixed(0) : 'N/A');
  " 2>/dev/null || echo "N/A")

  SI_VAL=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    const si = data.audits['speed-index'];
    console.log(si ? si.numericValue.toFixed(0) : 'N/A');
  " 2>/dev/null || echo "N/A")

  TBT_VAL=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    const tbt = data.audits['total-blocking-time'];
    console.log(tbt ? tbt.numericValue.toFixed(0) : 'N/A');
  " 2>/dev/null || echo "N/A")

  PERFORMANCE_SCORE=$(node -e "
    const data = require('./$LIGHTHOUSE_JSON');
    console.log(data.categories.performance.score * 100);
  " 2>/dev/null || echo "0")
fi

# ---------------------------------------------------------------------------
# 3. Fetch HTML for heuristic analysis
# ---------------------------------------------------------------------------

info "Fetching page content for heuristic analysis..."
HTML_CONTENT=$(curl -sL --max-time 30 "$TARGET_URL" 2>/dev/null || echo "")
HTML_SIZE=$(echo "$HTML_CONTENT" | wc -c | tr -d ' ')

if [ -z "$HTML_CONTENT" ]; then
  fail "Could not fetch URL: $TARGET_URL"
  log_result "FAIL" "Could not fetch URL: $TARGET_URL"
  echo ""
  echo "Report saved to: $REPORT_FILE"
  exit 1
fi

# ---------------------------------------------------------------------------
# 4. Core Web Vitals Checks
# ---------------------------------------------------------------------------

echo ""
echo "--- Core Web Vitals ---"
echo "" >> "$REPORT_FILE"
echo "## Core Web Vitals" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# LCP (Largest Contentful Paint)
# Threshold: < 2.5s good, < 4s needs improvement, >= 4s poor
if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ "$LCP_VAL" != "N/A" ]; then
  LCP_MS=$(echo "$LCP_VAL" | awk '{print int($1)}')
  if [ "$LCP_MS" -lt 2500 ]; then
    pass "LCP: ${LCP_MS}ms (Good)"
    log_result "PASS" "LCP: ${LCP_MS}ms (Good)"
  elif [ "$LCP_MS" -lt 4000 ]; then
    warn "LCP: ${LCP_MS}ms (Needs Improvement)"
    log_result "WARN" "LCP: ${LCP_MS}ms (Needs Improvement)"
  else
    fail "LCP: ${LCP_MS}ms (Poor)"
    log_result "FAIL" "LCP: ${LCP_MS}ms (Poor)"
  fi
else
  # Heuristic: Check for large images that could slow LCP
  LARGE_IMAGES=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | grep -oE 'src="[^"]+"' | wc -l | tr -d ' ')
  if [ "$LARGE_IMAGES" -gt 5 ]; then
    warn "LCP: Many images detected ($LARGE_IMAGES). Consider lazy loading or optimization."
    log_result "WARN" "LCP: Many images detected ($LARGE_IMAGES). Consider lazy loading or optimization."
  else
    pass "LCP: Image count looks reasonable ($LARGE_IMAGES)"
    log_result "PASS" "LCP: Image count looks reasonable ($LARGE_IMAGES)"
  fi
fi

# CLS (Cumulative Layout Shift)
# Threshold: < 0.1 good, < 0.25 needs improvement, >= 0.25 poor
if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ "$CLS_VAL" != "N/A" ]; then
  CLS_NUM=$(echo "$CLS_VAL" | awk '{print $1}')
  CLS_COMPARE=$(echo "$CLS_VAL" | awk '{if ($1 < 0.1) print "good"; else if ($1 < 0.25) print "improve"; else print "poor"}')
  if [ "$CLS_COMPARE" = "good" ]; then
    pass "CLS: $CLS_VAL (Good)"
    log_result "PASS" "CLS: $CLS_VAL (Good)"
  elif [ "$CLS_COMPARE" = "improve" ]; then
    warn "CLS: $CLS_VAL (Needs Improvement)"
    log_result "WARN" "CLS: $CLS_VAL (Needs Improvement)"
  else
    fail "CLS: $CLS_VAL (Poor)"
    log_result "FAIL" "CLS: $CLS_VAL (Poor)"
  fi
else
  # Heuristic: Check for images without width/height attributes (common CLS cause)
  IMG_WITHOUT_DIMS=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | grep -v 'width=' | grep -v 'height=' | wc -l | tr -d ' ')
  if [ "$IMG_WITHOUT_DIMS" -gt 0 ]; then
    warn "CLS: $IMG_WITHOUT_DIMS image(s) missing width/height attributes. Potential layout shift."
    log_result "WARN" "CLS: $IMG_WITHOUT_DIMS image(s) missing width/height attributes. Potential layout shift."
  else
    pass "CLS: All images have dimension attributes."
    log_result "PASS" "CLS: All images have dimension attributes."
  fi
fi

# INP (Interaction to Next Paint) - not directly available in older Lighthouse
# We'll use TBT as a proxy if available, or check for render-blocking JS
if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ "$TBT_VAL" != "N/A" ]; then
  TBT_MS=$(echo "$TBT_VAL" | awk '{print int($1)}')
  if [ "$TBT_MS" -lt 200 ]; then
    pass "TBT (INP proxy): ${TBT_MS}ms (Good)"
    log_result "PASS" "TBT (INP proxy): ${TBT_MS}ms (Good)"
  elif [ "$TBT_MS" -lt 600 ]; then
    warn "TBT (INP proxy): ${TBT_MS}ms (Needs Improvement)"
    log_result "WARN" "TBT (INP proxy): ${TBT_MS}ms (Needs Improvement)"
  else
    fail "TBT (INP proxy): ${TBT_MS}ms (Poor)"
    log_result "FAIL" "TBT (INP proxy): ${TBT_MS}ms (Poor)"
  fi
else
  # Heuristic: Check for render-blocking scripts
  RENDER_BLOCKING_SCRIPTS=$(echo "$HTML_CONTENT" | grep -oE '<script[^>]*>' | grep -v 'defer' | grep -v 'async' | grep -v 'type="module"' | wc -l | tr -d ' ')
  if [ "$RENDER_BLOCKING_SCRIPTS" -gt 2 ]; then
    warn "INP: $RENDER_BLOCKING_SCRIPTS render-blocking script(s) detected. Consider async/defer."
    log_result "WARN" "INP: $RENDER_BLOCKING_SCRIPTS render-blocking script(s) detected. Consider async/defer."
  else
    pass "INP: Script loading looks optimized."
    log_result "PASS" "INP: Script loading looks optimized."
  fi
fi

# FCP (First Contentful Paint)
if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ "$FCP_VAL" != "N/A" ]; then
  FCP_MS=$(echo "$FCP_VAL" | awk '{print int($1)}')
  if [ "$FCP_MS" -lt 1800 ]; then
    pass "FCP: ${FCP_MS}ms (Good)"
    log_result "PASS" "FCP: ${FCP_MS}ms (Good)"
  else
    warn "FCP: ${FCP_MS}ms (Needs Improvement)"
    log_result "WARN" "FCP: ${FCP_MS}ms (Needs Improvement)"
  fi
fi

# Speed Index
if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ "$SI_VAL" != "N/A" ]; then
  SI_MS=$(echo "$SI_VAL" | awk '{print int($1)}')
  if [ "$SI_MS" -lt 3400 ]; then
    pass "Speed Index: ${SI_MS}ms (Good)"
    log_result "PASS" "Speed Index: ${SI_MS}ms (Good)"
  else
    warn "Speed Index: ${SI_MS}ms (Needs Improvement)"
    log_result "WARN" "Speed Index: ${SI_MS}ms (Needs Improvement)"
  fi
fi

# ---------------------------------------------------------------------------
# 5. Image Optimization Check
# ---------------------------------------------------------------------------

echo ""
echo "--- Image Optimization ---"
echo "" >> "$REPORT_FILE"
echo "## Image Optimization" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

TOTAL_IMAGES=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | wc -l | tr -d ' ')
IMAGES_WITHOUT_ALT=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | grep -v 'alt=' | wc -l | tr -d ' ')
IMAGES_WITHOUT_LAZY=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | grep -v 'loading="lazy"' | wc -l | tr -d ' ')
IMAGES_WITHOUT_SRCSET=$(echo "$HTML_CONTENT" | grep -oE '<img[^>]+>' | grep -v 'srcset=' | wc -l | tr -d ' ')

if [ "$TOTAL_IMAGES" -eq 0 ]; then
  info "No images found on page."
  log_result "INFO" "No images found on page."
else
  info "Total images: $TOTAL_IMAGES"
  log_result "INFO" "Total images: $TOTAL_IMAGES"

  if [ "$IMAGES_WITHOUT_ALT" -gt 0 ]; then
    fail "$IMAGES_WITHOUT_ALT/$TOTAL_IMAGES image(s) missing alt attributes."
    log_result "FAIL" "$IMAGES_WITHOUT_ALT/$TOTAL_IMAGES image(s) missing alt attributes."
  else
    pass "All images have alt attributes."
    log_result "PASS" "All images have alt attributes."
  fi

  if [ "$IMAGES_WITHOUT_LAZY" -gt 3 ]; then
    warn "$IMAGES_WITHOUT_LAZY/$TOTAL_IMAGES image(s) not using lazy loading."
    log_result "WARN" "$IMAGES_WITHOUT_LAZY/$TOTAL_IMAGES image(s) not using lazy loading."
  else
    pass "Lazy loading is well-utilized."
    log_result "PASS" "Lazy loading is well-utilized."
  fi

  if [ "$IMAGES_WITHOUT_SRCSET" -eq "$TOTAL_IMAGES" ] && [ "$TOTAL_IMAGES" -gt 0 ]; then
    warn "No images use srcset for responsive images."
    log_result "WARN" "No images use srcset for responsive images."
  else
    pass "Responsive images (srcset) detected."
    log_result "PASS" "Responsive images (srcset) detected."
  fi
fi

# ---------------------------------------------------------------------------
# 6. Render-Blocking Resources
# ---------------------------------------------------------------------------

echo ""
echo "--- Render-Blocking Resources ---"
echo "" >> "$REPORT_FILE"
echo "## Render-Blocking Resources" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check for external stylesheets in <head> without media or async
EXTERNAL_STYLES=$(echo "$HTML_CONTENT" | grep -oE '<link[^>]*rel="stylesheet"[^>]*>' | wc -l | tr -d ' ')
RENDER_BLOCKING_CSS=$(echo "$HTML_CONTENT" | grep -oE '<link[^>]*rel="stylesheet"[^>]*>' | grep -v 'media=' | grep -v 'disabled' | wc -l | tr -d ' ')

if [ "$RENDER_BLOCKING_CSS" -gt 2 ]; then
  warn "$RENDER_BLOCKING_CSS render-blocking stylesheet(s) found. Consider inlining critical CSS."
  log_result "WARN" "$RENDER_BLOCKING_CSS render-blocking stylesheet(s) found. Consider inlining critical CSS."
else
  pass "Stylesheet loading is optimized."
  log_result "PASS" "Stylesheet loading is optimized."
fi

# Check for preload/prefetch hints
PRELOAD_HINTS=$(echo "$HTML_CONTENT" | grep -oE '<link[^>]*rel="preload"[^>]*>' | wc -l | tr -d ' ')
if [ "$PRELOAD_HINTS" -gt 0 ]; then
  pass "$PRELOAD_HINTS resource preload hint(s) found."
  log_result "PASS" "$PRELOAD_HINTS resource preload hint(s) found."
else
  warn "No resource preload hints found."
  log_result "WARN" "No resource preload hints found."
fi

# Check for preconnect hints
PRECONNECT_HINTS=$(echo "$HTML_CONTENT" | grep -oE '<link[^>]*rel="preconnect"[^>]*>' | wc -l | tr -d ' ')
if [ "$PRECONNECT_HINTS" -gt 0 ]; then
  pass "$PRECONNECT_HINTS preconnect hint(s) found."
  log_result "PASS" "$PRECONNECT_HINTS preconnect hint(s) found."
else
  warn "No preconnect hints found. Consider adding for external domains."
  log_result "WARN" "No preconnect hints found. Consider adding for external domains."
fi

# ---------------------------------------------------------------------------
# 7. HTML Size Check
# ---------------------------------------------------------------------------

echo ""
echo "--- HTML Size ---"
echo "" >> "$REPORT_FILE"
echo "## HTML Size" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$HTML_SIZE" -gt 500000 ]; then
  fail "HTML document is very large: ${HTML_SIZE} bytes. Consider code splitting."
  log_result "FAIL" "HTML document is very large: ${HTML_SIZE} bytes. Consider code splitting."
elif [ "$HTML_SIZE" -gt 100000 ]; then
  warn "HTML document is large: ${HTML_SIZE} bytes."
  log_result "WARN" "HTML document is large: ${HTML_SIZE} bytes."
else
  pass "HTML document size is reasonable: ${HTML_SIZE} bytes."
  log_result "PASS" "HTML document size is reasonable: ${HTML_SIZE} bytes."
fi

# ---------------------------------------------------------------------------
# 8. Compression Check
# ---------------------------------------------------------------------------

echo ""
echo "--- Compression ---"
echo "" >> "$REPORT_FILE"
echo "## Compression" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

ACCEPT_ENCODING=$(curl -sI --max-time 30 -H "Accept-Encoding: gzip, br" "$TARGET_URL" 2>/dev/null | grep -i "content-encoding" || echo "")
if [ -n "$ACCEPT_ENCODING" ]; then
  pass "Compression enabled: $(echo "$ACCEPT_ENCODING" | head -1 | sed 's/^[[:space:]]*//')"
  log_result "PASS" "Compression enabled: $(echo "$ACCEPT_ENCODING" | head -1 | sed 's/^[[:space:]]*//')"
else
  warn "No compression detected. Enable gzip or Brotli."
  log_result "WARN" "No compression detected. Enable gzip or Brotli."
fi

# ---------------------------------------------------------------------------
# 9. Caching Headers
# ---------------------------------------------------------------------------

echo ""
echo "--- Caching Headers ---"
echo "" >> "$REPORT_FILE"
echo "## Caching Headers" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

CACHE_CONTROL=$(curl -sI --max-time 30 "$TARGET_URL" 2>/dev/null | grep -i "cache-control" || echo "")
if [ -n "$CACHE_CONTROL" ]; then
  pass "Cache-Control header present: $(echo "$CACHE_CONTROL" | head -1 | sed 's/^[[:space:]]*//')"
  log_result "PASS" "Cache-Control header present: $(echo "$CACHE_CONTROL" | head -1 | sed 's/^[[:space:]]*//')"
else
  warn "No Cache-Control header found."
  log_result "WARN" "No Cache-Control header found."
fi

# ---------------------------------------------------------------------------
# 10. Lighthouse Performance Score (if available)
# ---------------------------------------------------------------------------

if [ "$LIGHTHOUSE_AVAILABLE" = true ] && [ -n "$PERFORMANCE_SCORE" ]; then
  echo ""
  echo "--- Lighthouse Performance Score ---"
  echo "" >> "$REPORT_FILE"
  echo "## Lighthouse Performance Score" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"

  SCORE_INT=$(echo "$PERFORMANCE_SCORE" | awk '{print int($1)}')
  if [ "$SCORE_INT" -ge 90 ]; then
    pass "Performance Score: ${SCORE_INT}/100 (Good)"
    log_result "PASS" "Performance Score: ${SCORE_INT}/100 (Good)"
  elif [ "$SCORE_INT" -ge 50 ]; then
    warn "Performance Score: ${SCORE_INT}/100 (Needs Improvement)"
    log_result "WARN" "Performance Score: ${SCORE_INT}/100 (Needs Improvement)"
  else
    fail "Performance Score: ${SCORE_INT}/100 (Poor)"
    log_result "FAIL" "Performance Score: ${SCORE_INT}/100 (Poor)"
  fi
fi

# ---------------------------------------------------------------------------
# 11. Summary
# ---------------------------------------------------------------------------

echo ""
echo "========================================"
echo "  Audit Complete"
echo "========================================"
echo ""

PASS_COUNT=$(grep -c "^PASS" "$REPORT_FILE" || echo "0")
WARN_COUNT=$(grep -c "^WARN" "$REPORT_FILE" || echo "0")
FAIL_COUNT=$(grep -c "^FAIL" "$REPORT_FILE" || echo "0")

echo "Summary:"
echo "  ${GREEN}PASS:${NC} $PASS_COUNT"
echo "  ${YELLOW}WARN:${NC} $WARN_COUNT"
echo "  ${RED}FAIL:${NC} $FAIL_COUNT"
echo ""

# Append summary to report
cat >> "$REPORT_FILE" << SUMMARY

---

## Summary

| Status | Count |
|--------|-------|
| PASS   | $PASS_COUNT |
| WARN   | $WARN_COUNT |
| FAIL   | $FAIL_COUNT |

SUMMARY

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "${RED}Issues found. Review the report for details.${NC}"
  echo ""
  echo "Report saved to: $REPORT_FILE"
  exit 1
else
  echo -e "${GREEN}All checks passed!${NC}"
  echo ""
  echo "Report saved to: $REPORT_FILE"
  exit 0
fi
