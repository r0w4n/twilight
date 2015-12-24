#!/bin/bash

main() {
    source settings.cnf

    if test `/usr/bin/find $savePath -name "sun.json" -mtime 1` 
    then
        $(downloadData)
    fi
}

downloadData() {
    /usr/bin/wget "http://api.sunrise-sunset.org/json?lat=${latitude}&lng=${longitude}" -O "${savePath}sun.json" >/dev/null 2>&1
}

main "$@"
