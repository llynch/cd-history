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

  # filtre results and show line numbers
  # TODO use many arguments as many pattern to match using grep. ex. "cdd test
  #      python" should match a line with test AND python.
  cdhistorygreped=$(mktemp)
  cdhistorygrepedcolored=$(mktemp)

  # show result with line numbers
  # mark current directory with a *

  # now we iterate through all the argument and ensure every one match
  #   this allow: 
  #      cdd test python
  #   matching path containing test and python

  cp $cdhistory $tmp
  #bldred='\e[1;31m' # Red
  #txtrst='\e[0m'    # Text Reset
  for arg in $*;
  do
      # show some color!
      # https://wiki.archlinux.org/index.php/Color_Bash_Prompt
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

      #show restults
      $DEBUG && echo "show results"
      cat $cdhistorygreped | sed "s#^$(pwd)\$#\*\ &#g"  | nl  | while line;
      do
        echo -n "$line"
      done

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

