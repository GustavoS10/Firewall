# scripts/wait-for-it.sh
#!/bin/sh
set -e

host="$1"
shift
cmd="$@"

until ping -c 1 "$host" > /dev/null 2>&1; do
  >&2 echo "Gateway is unavailable - sleeping"
  sleep 1
done

>&2 echo "Gateway is up - executing command"
exec $cmd
