ocaml --version 1>/dev/null || brew install ocaml
opam --version 1>/dev/null || (brew install opam && opam init --no)
opam show yojson 1>/dev/null || opam install yojson --yes
