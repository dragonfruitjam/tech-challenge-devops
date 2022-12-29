#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
cd "${DIR}"

if [[ -z "${DYNAMODB_ENDPOINT_ENV}" ]]; then
  echo "No environment variable"
  DYNAMODB_ENDPOINT="http://localhost:8000" python3 handler_as_app.py
else
  echo "environment variable"
  echo $DYNAMODB_ENDPOINT_ENV
  DYNAMODB_ENDPOINT="http://${DYNAMODB_ENDPOINT_ENV}:8000" python3 handler_as_app.py
fi

