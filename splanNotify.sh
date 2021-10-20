#!/bin/sh


# handle parameters and flags
read -d '' usage << EOF
Usage: $0 [OPTION]... <URL>
Notify at change of timetable(from StarPlan)

with no URL, or when URL is -, read standard input.

  -h            shows this help page
  -v            notifications for all lectures
  -q            no notifications even on change
EOF

while getopts "hvq" opt; do
  case "$opt" in
    h)
      echo "${usage}"
      exit 0
      ;;
    v)  verbose="y"
      ;;
    q)  quiet="y"
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

if [ ! -z ${verbose} ]; then
   Notifications=$(echo "${curlData}" | ./ttParser -d )
fi


# print stuff:

if [ -z ${quiet} ]; then
    while read line; do 
        if [ ! -z ${verbose} ]; then
            notify-send -i "${imageFile}" "$(echo ${line} | awk -F\; '{print $2}' | cut -d, -f1)" "$(echo ${line} | awk -F\; '{printf $1 " " $6 "\072 " $3 " @ " $5}')"
        fi
        # echo $(echo "${line}" | awk -F\; '{print "$2" "$3"}') 
    done < <(echo "${Notifications}")
fi
