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
    for command in tar sha256sum mktemp install cp mv; do
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

    package=musaranho-0.1.5-x86_64-unknown-linux-gnu
    archive="$package.tar.gz"
    temporary="$(mktemp -d)"
    staged_binary=''
    trap 'rm -rf -- "$temporary"; if [[ -n "$staged_binary" ]]; then rm -f -- "$staged_binary"; fi' EXIT
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
    [[ "$("$temporary/$package/musaranho" --version)" == 'musaranho 0.1.5' ]] || { echo 'Executável incompatível ou versão inesperada.' >&2; exit 1; }

    bin_dir="$HOME/.local/bin"
    notices="$HOME/.local/share/musaranho-cli"
    mkdir -p -- "$bin_dir" "$notices"
    cp -R -- "$temporary/$package/licenses" "$notices/"
    cp -- "$temporary/$package/LICENSE" "$temporary/$package/BINARY-LICENSE.txt" "$temporary/$package/THIRD_PARTY_NOTICES.md" "$notices/"
    staged_binary="$(mktemp "$bin_dir/.musaranho.XXXXXX")"
    install -m 0755 -- "$temporary/$package/musaranho" "$staged_binary"
    mv -fT -- "$staged_binary" "$bin_dir/musaranho"
    staged_binary=''
    printf '\nMusaranho instalado em %s/musaranho\nLicenças em %s\n\n' "$bin_dir" "$notices"
    printf '%s\n' 'Execute no seu terminal:' '  export PATH="$HOME/.local/bin:$PATH"' '  musaranho token create --name teste' '  musaranho serve' '' 'Swagger: http://127.0.0.1:8888/docs' 'Esta prévia ainda não inclui inferência.'
    exit 0
)

main "$@"
