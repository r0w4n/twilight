#!/bin/bash

main() {
    doLoadSettings

    if [ -z "$savePath" ]; then
        savePath=/tmp/
    fi

    doLoadParamters $1 $2 $3 $4
    doValidation $1

    if $(isOldJson); then
        doDownloadJson
    fi

#            echo $"Usage: $0 {sunrise|sunset|nautical-start|nautical-end|astromical-start|astronomical-send|civil-start|civil-end|noon|day-length}"

    if [ -z "$dateFormat" ]; then
        getField ${parameterMap[$1]}
    else
        getField ${parameterMap[$1]} | xargs date +${dateFormat} -d
    fi
}

doLoadSettings() {
    if [ -f "$(dirname ${BASH_SOURCE[0]})"/settings.cnf ]; then
        source "$(dirname ${BASH_SOURCE[0]})"/settings.cnf
    fi
}

doLoadParamters() {
    if [ -n "$2" ]; then
        latitude=$2
    fi

    if [ -n "$3" ]; then
        longitude=$3
    fi

    if [ -n "$4" ]; then
        dateFormat=$4
    fi
}

isOldJson() {
    if [[ -f $(getFilePath) &&  $(/bin/date +%s -r $(getFilePath)) -ge $(/bin/date -d 'today 00:00:00' '+%s') ]]; then
        return 1
    fi
    return 0
}

doDownloadJson() {
    /usr/bin/wget "http://api.sunrise-sunset.org/json?lat=${latitude}&lng=${longitude}&formatted=0" -O $(getFilePath) >/dev/null 2>&1
}

getField() {
    cat $(getFilePath) | jq -r .results.$1
}

getFilePath() {
    echo "${savePath}twilight${latitude}${longitude}.json"
}

doValidation() {
    if [ -z "$1" ]; then
       doShowMessage
       exit 1
    fi

    if [ ! ${parameterMap[$1]} ]; then
       doShowMessage
       exit 1
    fi

    if [ -z "$latitude" ]; then
       echo "latitude not provided"
       doShowMessage
       exit 1
    fi

    if [ -z "$longitude" ]; then
       echo "longitude not provided"
       doShowMessage
       exit 1
    fi
}

doShowMessage() {
    echo "usage: twlight ..."
    echo $"Usage: $0 {sunrise|sunset|nautical-start|nautical-end|astromical-start|astronomical-send|civil-start|civil-end|noon|day-length}"

}

    declare -A parameterMap
    parameterMap[sunrise]=sunrise
    parameterMap[sunset]=sunset
    parameterMap[noon]=solar_noon
    parameterMap[day-length]=day_length
    parameterMap[civil-start]=civil_twilight_begin
    parameterMap[civil-end]=civil_twilight_end
    parameterMap[nautical-start]=nautical_twilight_start
    parameterMap[nautical-end]=nautical_twilight_end
    parameterMap[astronomical-start]=astronomical_twilight_begin
    parameterMap[astronomical-end]=astronomical_twilight_end]

main "$@"
