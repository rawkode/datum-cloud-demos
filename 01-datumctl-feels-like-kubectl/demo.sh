#!/usr/bin/env bash
#
# Live-demo driver for "datumctl feels like kubectl".
#
# Each step types the command out, waits for you to press Enter, then runs it.
# Press Enter again to advance. Ctrl-C to bail.
#
# Configure with env vars (see README.md):
#   DEMO_ORG       organisation id            (required)
#   DEMO_PROJECT   project id                 (required)
#   DEMO_ALT_CTX   a second context to switch to, e.g. "my-org/staging" (optional)
#   DEMO_ZONE      a DNS zone name to describe (optional; defaults to the first zone found)
#   DEMO_LABEL     label selector for the -l beat (default: env=prod)
#   DEMO_KUBECONFIG scratch kubeconfig for the closing kubectl beat (default: ~/.kube/datum)
#   DEMO_KUBECTL   set to 0 to skip the closing kubectl beat (default: 1)
#   DEMO_TYPE_MS   per-character typing delay in ms (default: 25; 0 to disable)

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/demo.sh"

: "${DEMO_ORG:?set DEMO_ORG}"
: "${DEMO_PROJECT:?set DEMO_PROJECT}"
DEMO_LABEL="${DEMO_LABEL:-env=prod}"
DEMO_KUBECONFIG="${DEMO_KUBECONFIG:-~/.kube/datum}"
CTX="${DEMO_ORG}/${DEMO_PROJECT}"

clear

note "Cold open: the command your fingers already know"
run "kubectl get pods --help | head -3"
pause; clear

note "Beat 1: authenticate"
run "datumctl --help"
run "datumctl logout"
run "datumctl login"
run "datumctl whoami"
pause; clear

note "Beat 2: contexts  (kubectl config get-contexts / use-context)"
run "datumctl ctx"
if [[ -n "${DEMO_ALT_CTX:-}" ]]; then
  run "datumctl ctx use ${DEMO_ALT_CTX}"
  run "datumctl whoami"
fi
run "datumctl ctx use ${CTX}"
run "datumctl whoami"
note "Per-command override, like kubectl --context"
run "datumctl get projects --organization ${DEMO_ORG}"
run "DATUM_PROJECT=${DEMO_PROJECT} datumctl whoami"
pause; clear

note "Beat 3: discover resources  (kubectl api-resources / explain)"
run "datumctl api-resources"
run "datumctl api-resources --api-group=dns.networking.miloapis.com -o wide"
run "datumctl explain dnszones"
run "datumctl explain dnszones.spec"
pause; clear

note "Beat 4: get and describe"
run "datumctl get dnszones"
run "datumctl get dnszones -o wide"
run "datumctl get dnszones -o yaml | head -40"
run "datumctl get dnszones -o jsonpath='{.items[*].metadata.name}'; echo"
run "datumctl get dnszones -l ${DEMO_LABEL}"

zone="${DEMO_ZONE:-}"
if [[ -z "$zone" ]]; then
  zone="$(datumctl get dnszones -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
fi
if [[ -n "$zone" ]]; then
  run "datumctl describe dnszone ${zone}"
else
  note "(no DNS zones found; skipping describe)"
fi
pause; clear

if [[ "${DEMO_KUBECTL:-1}" == "1" ]]; then
  note "Closing surprise: put datumctl down and pick up plain kubectl" \
       "The kubeconfig goes to ${DEMO_KUBECONFIG}, not ~/.kube/config" \
       "kubectl calls 'datumctl auth get-token' for the credential; show that in the config view"
  run "datumctl auth update-kubeconfig --project ${DEMO_PROJECT} --kubeconfig ${DEMO_KUBECONFIG}"
  run "export KUBECONFIG=${DEMO_KUBECONFIG}"
  run "kubectl api-resources --api-group=dns.networking.miloapis.com"
  run "kubectl get dnszones"
  if [[ -n "$zone" ]]; then
    run "kubectl describe dnszone ${zone}"
  fi
  run "kubectl config view --minify"
  pause; clear
fi

note "Recap"
cat <<'RECAP'
  datumctl login
  datumctl ctx
  datumctl api-resources
  datumctl get <resource>
  datumctl describe <resource> <name>

  datumctl auth update-kubeconfig --project <project>
  kubectl get <resource>

  If you know kubectl, you knew all of this already.
RECAP
printf '\n'
