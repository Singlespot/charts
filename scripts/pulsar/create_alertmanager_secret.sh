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
       --slack-api-url                  Slack API url
       --slack-channel                  Slack channel
Usage:
    $0 --namespace pulsar --slack-api-url <slack_api_url> --slack-channel <slack_channel>
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
    --slack-api-url)
    slack_api_url="$2"
    shift
    shift
    ;;
    --slack-channel)
    slack_channel="$2"
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
secret_name="alertmanager-secret"

function generate_alertmanager_secret() {
    kubectl create secret generic ${secret_name} -n ${namespace} \
      --from-literal="SLACK_API_URL=${slack_api_url}" \
      --from-literal="SLACK_CHANNEL=${slack_channel}" \
      --dry-run=client -o yaml | kubectl -n ${namespace} apply -f -
}
generate_alertmanager_secret
