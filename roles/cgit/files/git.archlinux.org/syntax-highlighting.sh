#!/bin/bash

checklang() {
  # If this returns true, then the extension is known
  echo | /usr/bin/highlight -f -S "$1" >/dev/null 2>/dev/null
}

BASENAME="$1"
EXTENSION="${BASENAME##*.}"

# map Makefile and Makefile.* to .mk
[[ "${BASENAME%%.*}" == "Makefile" ]] && EXTENSION=mk
# map PKGBUILD and install to sh
[[ "$1" == "PKGBUILD" || "${EXTENSION}" == "install" ]] && EXTENSION=sh

PRINTLINE=n
if ! checklang "$EXTENSION"; then
  read -r LINE
  PRINTLINE=y
  if [[ "${LINE:0:2}" == "#!" ]]; then
    # shebang detected
    SHEBANG=${LINE##*/}
    if [[ ${SHEBANG:0:3} == "env" ]]; then
      # Assume #!/usr/bin/env foo
      SHEBANG=${SHEBANG#* }
    fi
    SHEBANG=${SHEBANG%% *}
    EXTENSION=${SHEBANG}
  fi
  [[ "$SHEBANG" == "python2" || "$SHEBANG" == "python3" ]] && EXTENSION=py
  if ! checklang "$EXTENSION"; then
    EXTENSION="txt"
  fi
fi

(if [[ $PRINTLINE == y ]]; then
   echo "$LINE"
 fi
 cat
) | /usr/bin/highlight --failsafe --force -f -I -O xhtml -S "$EXTENSION" 2>/dev/null
