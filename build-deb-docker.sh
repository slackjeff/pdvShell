#!/bin/sh

set -eu

red=$(printf '\033[31m')
green=$(printf '\033[32m')
yellow=$(printf '\033[33m')
blue=$(printf '\033[34m')
reset=$(printf '\033[0m')

quiet=0

usage() {
	printf '%sUso:%s %s [opções]\n\n' "$blue" "$reset" "$0"
	printf '%sOpções:%s\n' "$blue" "$reset"
	printf '  --help           Mostra esta ajuda\n'
	printf '  -q, --quiet      Mostra somente erros\n'
}

while [ $# -gt 0 ]; do
	case "$1" in
	--help)
		usage
		exit 0
		;;
	-q | --quiet)
		quiet=1
		shift
		;;
	*)
		printf '%sErro: opção desconhecida: %s%s\n\n' "$red" "$1" "$reset"
		printf 'Use "%s --help" para ajuda.\n' "$(basename "$0")"
		exit 1
		;;
	esac
done

pkgver=$(date +%Y%m%d)
pkgrel=$(date +%H%M)

cat > debian/changelog <<EOF
pdvshell (${pkgver}-${pkgrel}) unstable; urgency=medium

  * Debian release.

 -- Vilmar Catafesta <vcatafesta@gmail.com>  $(date -R)
EOF

script=$(realpath "$0")
script_name=$(basename "$script")
project_dir=$(dirname "$script")

printf '%s%s --help para ajuda%s\n' "$yellow" "$script_name" "$reset"

if [ ! -d "$project_dir/debian" ]; then
	printf '%sErro: diretório debian não encontrado:%s\n' "$red" "$reset"
	printf '  %s\n' "$project_dir/debian"
	exit 1
fi

printf '%s==> Projeto:%s %s\n' "$blue" "$reset" "$project_dir"
printf '%s==> Diretório debian:%s OK\n' "$green" "$reset"
printf '%s==> Construindo pacote Debian...%s\n' "$yellow" "$reset"

if [ "$quiet" -eq 0 ]; then
	docker run --rm -it \
		-v "$project_dir:/build" \
		-w /build \
		debian:stable-slim \
		sh -c '
			set -eu
			export DEBIAN_FRONTEND=noninteractive
			apt-get update
			apt-get install -y debhelper-compat dpkg-dev
			dpkg-buildpackage -us -uc -b
			deb=$(find .. -maxdepth 1 -type f -name "*.deb" -print -quit)
			if [ -z "$deb" ]; then
				echo "Erro: pacote .deb não foi gerado." >&2
				exit 1
			fi

			apt-get install -y "$deb"
			pdvshell
			cp "$deb" /build/

		'
else
	if ! output=$(
		docker run --rm \
			-v "$project_dir:/build" \
			-w /build \
			debian:stable-slim \
			sh -c '
				set -eu
				export DEBIAN_FRONTEND=noninteractive
				apt-get update
				apt-get install -y debhelper-compat dpkg-dev
				dpkg-buildpackage -us -uc -b
				deb=$(find .. -maxdepth 1 -type f -name "*.deb" -print -quit)

				if [ -z "$deb" ]; then
					echo "Erro: pacote .deb não foi gerado." >&2
					exit 1
				fi

				#apt-get install -y "$deb"
				#pdvshell
				cp "$deb" /build/

			' 2>&1
	); then
		printf '%s%s%s\n' "$red" "$output" "$reset"
		exit 1
	fi
fi

printf '%s==> Build concluído com sucesso.%s\n' "$green" "$reset"
