#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

usage() {
    cat <<EOF
This script is used to bootstrap the pulsar namespace before deploying a helm chart. 
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart
       --client-id                      GitHub OAuth app client id
       --client-secret                  GitHub OAuth app client secret
Usage:
    $0 --namespace pulsar --release pulsar-release --client-id <client_id> --client-secret <client_secret>
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
    --client-id)
    client_id="$2"
    shift
    shift
    ;;
    --client-secret)
    client_secret="$2"
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
release=${release:-pulsar-dev}
secret_name="grafana-github-secret"

function generate_grafana_github_secret() {
    local secret_name="grafana-github-secret"
    kubectl create secret generic ${secret_name} -n ${namespace} \
        --from-literal="GF_AUTH_GITHUB_CLIENT_ID=${client_id}" \
        --from-literal="GF_AUTH_GITHUB_CLIENT_SECRET=${client_secret}"
}
generate_grafana_github_secret