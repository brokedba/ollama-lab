#!/bin/bash
# Exit if any of the intermediate steps fail
set -e -o nounset -o pipefail -o xtrace
# Read the JSON payload from stdin
# cat - > log.out
# read -r input  #echo $input
export KUBECONFIG="kubeconfig"
# Parse JSON input and extract namespace and name
eval "$(jq -r '@sh "namespace=\(.namespace) name=\(.name)"')" 
# echo "Parsed namespace: $namespace"
# echo "Parsed name: $name"
for i in {1..30}; do
  hostname=$(kubectl get ingress -n "${namespace}" "${name}" --kubeconfig=kubeconfig -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [[ -n "$hostname" ]]; then
    echo "{\"hostname\":\"$hostname\"}"
    exit 0
  fi
  echo "Waiting for Ingress hostname to be ready..."
  sleep 10
done

echo "{\"error\":\"Ingress hostname not ready after timeout\"}"
exit 1