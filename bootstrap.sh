# This bootstrap is just a way to make your shell cd into the directory
# found by the python script. The real work is done by this one.

cd_history_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
echo $(dirname "${BASH_SOURCE[0]}")


alias cdh="python $cd_history_dir/cd-history.py"
function c() {
	\cd "`cdh search $*`"
}

# With these lines in your .bashrc, you have to :
# - type 'cdh add' to add the current directory to search list
# - type 'cdh add <directory>' to add the <directory> to search list
# - type 'cdh list' to list the indexed directory
# - type 'c <pattern>' to search the <pattern> and jump to the right directory

# If you want to index all visited directory, try to add these lines :

function cdh_cd() {
	\cd "$@" && cdh add
}
alias cd='cdh_cd'
