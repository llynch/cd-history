# No particular shell specified. You should use it as a tool in your favorite shell.
# Tested in bash and should work in sh.

cdhistory=~/.cd_history
#cdhistorygreped=~/.cd_history_greped
alias cd="cdh"
cdh() { \cd "$*"; pwd >> $cdhistory; }

cdd() { 

  DEBUG="false"
  # dont execute this function if history is empty
  if [ ! -f $cdhistory ];
  then return; fi

  # sort the file and eliminate duplicate
  tmp=$(mktemp)
  sort $cdhistory | uniq > $tmp
  cp $tmp $cdhistory

  cdhistorygreped=$(mktemp)
  cdhistorygrepedcolored=$(mktemp)
  # now we iterate through all the argument and ensure every one match
  #   this allow: 
  #      cdd test python
  #   matching path containing test and python

  cp $cdhistory $tmp
  # show some color!
  # https://wiki.archlinux.org/index.php/Color_Bash_Prompt
  #bldred='\e[1;31m' # Red
  #txtrst='\e[0m'    # Text Reset
  if [ "$*" == "" ]; then
      grep="cat"
  else
      grep="grep -i --color -e '/'"
  fi
  for arg in $*;
  do
      grep="$grep -e $arg"
      cat $tmp | sed -n "s#$arg#&#ip" > $cdhistorygreped
      #$DEBUG && cat $cdhistorygreped
      #cat $tmp | grep -i "$arg" > $cdhistorygreped

      cp $cdhistorygreped $tmp
  done
  cp $tmp $cdhistorygreped

  $DEBUG && echo "filter done" 
  # get the number of results for expression
  nbResults=$(cat $cdhistorygreped | wc -l)
  if [ "$nbResults" == "1" ];
  then

    # only one result so cd to it directly
    \cd $(sed '1p' $cdhistorygreped)

  elif [ $nbResults == "0" ];
  then

    # no results matching query, then create
    echo "Sorry no result for $*"

  else

      #show restults whith line number and mark current directory
      $DEBUG && echo "show results"
      cat $cdhistorygreped | sed "s#^$(pwd)\$#\*\ &#g" | nl  | $grep

    # ask the user for a number
    echo -n "choose a number: "; 
    read line; 

    # execute user choice
    if [ "$line" != "" ]; 
    then 
      \cd $(sed -n "${line}p" $cdhistorygreped);
    fi; 

  fi;
}

