#!/usr/bin/env bash

usage() {
    cat <<EOF
This script is used to bootstrap the pulsar namespace before deploying a Helm chart.
Options:
       -h, --help                       prints the usage message
       -n, --namespace                  the k8s namespace to install the pulsar helm chart
       --github-client-id               GitHub client id
       --github-client-secret           GitHub client secret
Usage:
    $0 --namespace pulsar --github-client-id <github_client_id> --github-client-secret <github_client_secret>
EOF
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--namespace)
    namespace="$2"
    shift
    shift
    ;;
    --github-client-id)
    github_client_id="$2"
    shift
    shift
    ;;
    --github-client-secret)
    github_client_secret="$2"
    shift
    shift
    ;;
    -h|--help)
    usage
    exit 0
    ;;
    *)
    echo "unknown option: $key"
    usage
    exit 1
    ;;
esac
done

namespace=${namespace:-pulsar}
secret_name="pulsar-manager-secret"

function generate_pulsar_manager_secret() {
    kubectl create secret generic ${secret_name} -n ${namespace} \
      --from-literal="GITHUB_CLIENT_ID=${github_client_id}" \
      --from-literal="GITHUB_CLIENT_SECRET=${github_client_secret}"
}
generate_pulsar_manager_secret
