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

  # we'll need temp files
  cdhistorygreped=$(mktemp)
  cdhistorygrepedcolored=$(mktemp)

  # now we iterate through all the argument and ensure every one match
  #   this allow: 
  #      cdd test python
  #   matching path containing test and python
  cp $cdhistory $tmp
  # show some color!
  # https://wiki.archlinux.org/index.php/Color_Bash_Prompt
  bldred=$(echo -e '\e[1;33m') # Red
  colorreset=$(echo -e '\e[0m')    # Text Reset
  grep="cat"
  i=31 # start in red
  for arg in $*;
  do
      # prepare grep expression
      grep="$grep | grep -i $arg"

      # prepare a colored output
      color=$(echo -e "\e[1;${i}m")
      cat $tmp | sed -n "s#$arg#$color&$colorreset#ip" > $cdhistorygrepedcolored

      cp $cdhistorygrepedcolored $tmp
      i=$(expr $i + 1)
  done
  cp $tmp $cdhistorygrepedcolored

  # a non colored version of the results
  $DEBUG && echo "grep expression: $grep"
  eval "cat $cdhistory | $grep > $cdhistorygreped"

  $DEBUG && echo "filter done" 
  # get the number of results for expression
  nbResults=$(cat $cdhistorygrepedcolored | wc -l)
  if [ "$nbResults" == "1" ];
  then

    $DEBUG && echo "filtered"
    $DEBUG && cat $cdhistorygreped
    $DEBUG && echo "filtered colored"
    $DEBUG && cat $cdhistorygrepedcolored
    # only one result so cd to it directly
    directory=$(sed -n "1p" $cdhistorygreped | cat)
    $DEBU && echo "cd to $directory"
    \cd "$directory"

  elif [ $nbResults == "0" ];
  then

    # no results matching query, then create
    echo "Sorry no result for $*"

  else

    # show restults whith line number and mark current directory
    $DEBUG && echo "show results"
    $DEBUG && cat $cdhistorygreped
    cat $cdhistorygrepedcolored | sed "s#^$(pwd)\$#\*\ &#g" | nl

    # ask the user for a number
    echo -n "choose a number: "; 
    read line; 

    # execute user choice
    if [ "$line" != "" ]; 
    then 
      directory=$(sed -n "${line}p" $cdhistorygreped | cat)
      $DEBUG && echo $directory
      \cd "$directory"
    fi; 

  fi;

  # delete temp files
  /bin/rm $tmp
  /bin/rm $cdhistorygreped
  /bin/rm $cdhistorygrepedcolored
}

