#!/bin/sh


# handle parameters and flags
read -d '' usage << EOF
Usage: $0 [OPTION]... <URL>
Notify at change of timetable(from StarPlan)

with no URL, or when URL is -, read standard input.

  -h            shows this help page
  -v            notifications for all lectures
  -q            no notifications even on change
  -n            notification for next lecture
EOF

while getopts "hvqn" opt; do
  case "$opt" in
    h)
      echo "${usage}"
      exit 0
      ;;
    v)  verbose="y"
      ;;
    q)  quiet="y"
      ;;
    n)  nextLecture="y"
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      echo ${usage} >&2
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      echo ${usage} >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift


if [ -z "$1" ] || [ "$1" = "-" ]; then
    if [ -p /dev/stdin ]; then
        read -r url
    else
        echo "No stdin given" >&2
        exit 1
    fi
elif [ ! -z "$1" ]; then
    url="$1"
else
    echo "No url given" >&2
    echo ${usage} >&2
    exit 1
fi




storedTime="timeTable"
storedLecture="lectureTable"
imageFile="$(pwd)/th-rosenheim-logo-klein.png"
notCompare=""
url="${url}&m=getTT"
curlData=$(curl -s "${url}" | sed "s/></>\n</g")


# check directories and files
if [ -z "${XDG_CACHE_HOME}" ]; then
  dataDir="~/.splan"
else
  dataDir="${XDG_CACHE_HOME}/splan"
fi

if [ ! -d "${dataDir}" ]; then
    mkdir -p "${dataDir}"
    notCompare="true"
fi

if [ ! -f "${dataDir}/${storedLecture}" ]; then
    LectureTT=$(echo $(curlData) | ./ttParser )
    echo ${LectureTT} > "${dataDir}/${storedLecture}"
    notCompare="true"
fi

if [ ! -f "${dataDir}/${storedTime}" ]; then
    LectureTT=$(echo $(curlData) | ./ttParser -d )
    echo ${timeTable} > "${dataDir}/${storedTime}"
    notCompare="true"
fi

if [ -z ${notCompare}]; then
    :
fi

if [ ! -z ${nextLecture} ]; then
    while read line; do 
        dt1="$(echo "${line}" | awk -F\; 'match($0, /([0-1]?[0-9]|2[0-3]):[0-5][0-9]/, a) {print $1 " " a[0]}'):00"
        t1=$(date --date="${dt1}" +%s)

        dt2=$(date +%Y-%m-%d\ %H:%M:%S)
        t2=$(date --date="$dt2" +%s)

        let "tDiff=$t1-$t2"
        
        if [ ${tDiff} -gt 0 ] && ([ -z ${nextTime} ] || [ ${tDiff} -eq ${nextTime} ]); then 
            if [ -z ${Notifications} ]; then
                Notifications="${line}" 
            else
                Notifications="${Notifications}"$'\n'"${line}" 
            fi
            nextTime=${tDiff}
        fi
        # echo $(echo "${line}" | awk -F\; '{print "$2" "$3"}') 
    done < <(echo "${curlData}" | ./ttParser -d )

fi
if [ ! -z ${verbose} ]; then
    Notifications=$(echo "${curlData}" | ./ttParser -d )
fi


# print stuff:

if [ -z ${quiet} ]; then
    while read line; do 
            notify-send -i "${imageFile}" "$(echo ${line} | awk -F\; '{print $2}' | cut -d, -f1)" "$(echo ${line} | awk -F\; '{printf $1 " " $6 "\072 " $3 " @ " $5}')"
    done < <(echo "${Notifications}")
fi
