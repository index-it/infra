#!/bin/bash

BASE_DIR="apps"

# Optional first argument: app folder name
TARGET_APP="$1"

if [ -n "$TARGET_APP" ]; then
    SEARCH_DIR="$BASE_DIR/$TARGET_APP/envs"
    if [ ! -d "$SEARCH_DIR" ]; then
        echo "Folder $SEARCH_DIR does not exist."
        exit 1
    fi
else
    read -p "No app folder specified. This will run on all apps under $BASE_DIR. Continue? (y/N) " CONFIRM
    case "$CONFIRM" in
        [yY][eE][sS]|[yY]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
    SEARCH_DIR="$BASE_DIR"
fi

# Check for yq dependency
if ! command -v yq &>/dev/null; then
    echo "Error: 'yq' is required but not installed. Install it from https://github.com/mikefarah/yq"
    exit 1
fi

# Loop through all env folders and find 'secrets' directories
find "$SEARCH_DIR" -type d -path "*/envs/*/secrets" | while read -r SECRETS_DIR; do
    ENV_DIR="$(dirname "$SECRETS_DIR")"        # e.g. apps/{app}/envs/{env}
    ENV_NAME="$(basename "$ENV_DIR")"          # e.g. prod
    APP_DIR="$(dirname "$(dirname "$ENV_DIR")")" # e.g. apps/{app}
    BASE_OUT_DIR="$APP_DIR/base"

    mkdir -p "$BASE_OUT_DIR"

    # Process each *-secret.yml file
    for SECRET_FILE in "$SECRETS_DIR"/*-secret.yml; do
        [ -e "$SECRET_FILE" ] || continue

        FILE_BASENAME="$(basename "${SECRET_FILE%-secret.yml}")"
        SEALED_TMP="$(mktemp /tmp/sealed-XXXXXX.yml)"

        # Run kubeseal to produce the full sealed secret
        kubeseal -f "$SECRET_FILE" -w "$SEALED_TMP"
        echo "Sealed $SECRET_FILE"

        # ── ENV copy: keep only apiVersion, kind, metadata.name, spec.encryptedData ──
        ENV_OUT="$ENV_DIR/${FILE_BASENAME}-secret-sealed.yml"
        yq '
          {
            "apiVersion": .apiVersion,
            "kind": .kind,
            "metadata": {"name": .metadata.name},
            "spec": {"encryptedData": .spec.encryptedData}
          }
        ' "$SEALED_TMP" > "$ENV_OUT"
        # Prepend YAML document separator
        sed -i '1s/^/---\n/' "$ENV_OUT"
        echo "  -> env copy:  $ENV_OUT"

        # ── BASE copy: remove spec.encryptedData, remove metadata.namespace,
        #              add argocd sync-wave annotation ──
        BASE_OUT="$BASE_OUT_DIR/${FILE_BASENAME}-secret-sealed.yml"
        yq '
          del(.spec.encryptedData) |
          del(.metadata.namespace) |
          .metadata.annotations["argocd.argoproj.io/sync-wave"] = "-1"
        ' "$SEALED_TMP" > "$BASE_OUT"
        sed -i '1s/^/---\n/' "$BASE_OUT"
        echo "  -> base copy: $BASE_OUT"

        rm -f "$SEALED_TMP"
    done
done