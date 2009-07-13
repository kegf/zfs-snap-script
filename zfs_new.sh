#!/bin/sh

status=$( zpool status -x )
send=0
month_day=$( date "+%d" )
today=$( date "+%Y-%m-%d" )
backup_pool="tank/home"
month_depth="3"
day_depth="10"

if [ "${status}" != "all pools are healthy" ]; then
        zpoolmsg="Problems with ZFS: ${status}"
        send=1
else

case $month_day in
    01)
        zfs snapshot ${backup_pool}@${today}
        month=$( date -v-${month_depth}m +%Y-%m-%d )
        if [ ! -z $( zfs list -H -t snapshot -o name | grep $month ) ]; then
            zfs destroy ${backup_pool}@${month}
        fi
        ;;
    10|20|30 )
        zfs snapshot ${backup_pool}@${today}
        week=$( date -v-1m +%Y-%m-%d )
        if [ ! -z $( zfs list -H -t snapshot -o name | grep $week ) ]; then
            zfs destroy ${backup_pool}@${week}
        fi
        ;;
    *)
        echo "zfs snap"
        zfs snapshot ${backup_pool}@${today}
        day=$( date -v-${day_depth}d +%Y-%m-%d )

        if [ $month_day -ne "11" -a ! -z $( zfs list -H -t snapshot -o name | grep $day ) ]; then
            zfs destroy ${backup_pool}@${day}
        fi
        ;;
esac

fi

if [ "${send}" -eq 1 ]; then
        echo "${zpoolmsg}" | mail -s "Filesystem Issues on backup server" ilgiz@reid.ru
fi
