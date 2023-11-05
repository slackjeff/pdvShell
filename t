function inkey() {
    tempo="$1"
    [[ -z "$tempo" ]] && tempo=-1
    IFS= read -t "$tempo" -n 1 -s lastkey
    [[ -z "$lastkey" ]] && lastkey=""
}

function pausetty() {
	tempo="$1"
	msg="$2"
    >/dev/tty printf '%s' "${msg:-Pressione qualquer tecla para continuar...}"
    [[ $ZSH_VERSION ]] && read -krs  # Use -u0 to read from STDIN
    [[ $BASH_VERSION ]] && </dev/tty read -t "$tempo" -rsn1
    printf '\n'
}

pausetty 5 "tecle algo"
