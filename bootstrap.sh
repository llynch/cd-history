# This bootstrap is just a way to make your shell cd into the directory
# the real work is done by the python script

cdd () {
    tmp=$(mktemp)
    python ~/projet/python/cd-history/cd-history.py $* 2> $tmp
    cd "$(cat $tmp)"
    /bin/rm $tmp
}
