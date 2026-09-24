#!/usr/bin/env bash
set -euo pipefail

main() (
    source=${1:-}
    if (( $# > 1 )); then
        echo 'Uso: bash install.sh [URL HTTPS da raiz da publicação]' >&2
        return 1
    fi
    platform="$(uname -s)/$(uname -m)"
    if [[ "$platform" != Linux/x86_64 ]]; then
        echo 'Esta prévia suporta somente Linux x86_64 com glibc compatível com a release.' >&2
        return 1
    fi
    for command in tar sha256sum mktemp install cp mv cmp mkdir rmdir; do
        command -v "$command" >/dev/null || { echo "Comando necessário: $command" >&2; return 1; }
    done
    if [[ -n "$source" ]]; then
        [[ "$source" == https://* ]] || { echo 'A URL deve usar HTTPS.' >&2; return 1; }
        command -v curl >/dev/null || { echo 'Instale curl primeiro.' >&2; return 1; }
        source=${source%/}
    else
        [[ -f "${BASH_SOURCE[0]}" ]] || { echo 'Informe a URL HTTPS da publicação ao executar via curl.' >&2; return 1; }
        source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    fi

    package=musaranho-0.2.6-x86_64-unknown-linux-gnu
    archive="$package.tar.gz"
    temporary="$(mktemp -d)"
    staged_binary=''
    staged_model=''
    trap 'rm -rf -- "$temporary"; if [[ -n "$staged_binary" ]]; then rm -f -- "$staged_binary"; fi; if [[ -n "$staged_model" ]]; then rm -rf -- "$staged_model"; fi' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    if [[ "$source" == https://* ]]; then
        curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' "$source/cli/$archive" -o "$temporary/$archive"
        curl --fail --silent --show-error --location --proto '=https' --proto-redir '=https' "$source/cli/SHA256SUMS" -o "$temporary/SHA256SUMS"
    else
        cp -- "$source/cli/$archive" "$source/cli/SHA256SUMS" "$temporary/"
    fi
    read -r checksum filename extra < "$temporary/SHA256SUMS"
    if [[ ! "$checksum" =~ ^[[:xdigit:]]{64}$ || "$filename" != "$archive" || -n "$extra" ]]; then
        echo 'Checksum inválido para esta versão.' >&2
        exit 1
    fi
    (cd "$temporary" && printf '%s  %s\n' "$checksum" "$archive" | sha256sum -c -)
    tar -xzf "$temporary/$archive" -C "$temporary" --no-same-owner --no-same-permissions
    [[ "$("$temporary/$package/musaranho" --version)" == 'musaranho 0.2.6' ]] || { echo 'Executável incompatível ou versão inesperada.' >&2; exit 1; }

    bin_dir="$HOME/.local/bin"
    notices="$HOME/.local/share/musaranho-cli"
    mkdir -p -- "$bin_dir" "$notices"
    model=musaranho-0.3
    model_dir="$notices/models/$model"
    read -r model_checksum model_archive model_url extra < "$temporary/$package/model-download.txt"
    [[ "$model_checksum" =~ ^[[:xdigit:]]{64}$ && "$model_archive" == "$model.tar.gz" && "$model_url" == https://* && -z "$extra" ]] || { echo 'Manifesto do modelo inválido.' >&2; exit 1; }
    if [[ -e "$model_dir" ]]; then
        [[ ! -L "$model_dir" ]] || { echo 'Diretório do modelo não pode ser um link.' >&2; exit 1; }
        cmp -- "$temporary/$package/model.json" "$model_dir/model.json"
        (cd "$model_dir" && sha256sum -c "$temporary/$package/model-SHA256SUMS")
    else
        if [[ "$source" != https://* && -f "$source/cli/$model_archive" ]]; then
            cp -- "$source/cli/$model_archive" "$temporary/$model_archive"
        else
            command -v curl >/dev/null || { echo 'Instale curl para baixar o modelo.' >&2; exit 1; }
            printf 'Baixando o modelo; este download tem aproximadamente 1,2 GB.\n'
            curl --fail --progress-bar --show-error --location --proto '=https' --proto-redir '=https' "$model_url" -o "$temporary/$model_archive"
        fi
        (cd "$temporary" && printf '%s  %s\n' "$model_checksum" "$model_archive" | sha256sum -c -)
        mkdir -p -- "$notices/models"
        staged_model="$(mktemp -d "$notices/models/.install.XXXXXX")"
        tar -xzf "$temporary/$model_archive" -C "$staged_model" --no-same-owner --no-same-permissions
        cmp -- "$temporary/$package/model.json" "$staged_model/$model/model.json"
        (cd "$staged_model/$model" && sha256sum -c "$temporary/$package/model-SHA256SUMS")
        mv -T -- "$staged_model/$model" "$model_dir"
        rmdir -- "$staged_model"
        staged_model=''
    fi
    cp -R -- "$temporary/$package/licenses" "$notices/"
    cp -- "$temporary/$package/LICENSE" "$temporary/$package/BINARY-LICENSE.txt" "$temporary/$package/THIRD_PARTY_NOTICES.md" "$notices/"
    staged_binary="$(mktemp "$bin_dir/.musaranho.XXXXXX")"
    install -m 0755 -- "$temporary/$package/musaranho" "$staged_binary"
    mv -fT -- "$staged_binary" "$bin_dir/musaranho"
    staged_binary=''
    printf '\nMusaranho instalado em %s/musaranho\nLicenças em %s\n\n' "$bin_dir" "$notices"
    printf '%s\n' 'Execute no seu terminal:' '  export PATH="$HOME/.local/bin:$PATH"' '  musaranho token create --name teste' '  musaranho serve' '' 'Swagger: http://127.0.0.1:8888/docs' 'Modelo musaranho-0.3 instalado para inferência local em CPU.'
    exit 0
)

main "$@"
