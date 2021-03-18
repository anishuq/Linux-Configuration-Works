#!/bin/bash

########################
resFileLoc=$HOME"/"".restore.info"
#echo $resFileLoc

if [ $# -lt 1 ]
then
   echo "File Name Not Provided."
   exit 1;
fi

found=1
dupFile=1
notMoved=1
fileToRestore=$1
wholeFileText=''
exec < $resFileLoc

SaveIFS=$IFS
while IFS=: read fIname absPath
do

  if [ "$fIname" = "$fileToRestore" ]
  then
     #echo "File found"
     found=0
     #test to see if duplicate file exists in destination
     if [ -f $absPath ]
     then
        dupFile=0;
        echo "Duplicate file exists. Do you want to overwrite? Y or N?"
        read choice < /dev/tty;

        initial="$(echo $choice | head -c 1)"

        case $initial in

           y|Y)
                echo -n "duplicate file found and overwritten."
                mv $HOME"/recyclebin/"$fIname $absPath
           ;;

           n|N)
               echo "file will not be moved for overwritting."
               notMoved=0;
               #this varaible is for file not moved in case of duplicate.

               #this file will not be moved, so its information must be kept.
               wholeFileText="$wholeFileText""$fIname:""$absPath""^"
               exit 0;
           ;;
           *)
             echo "Invalid argument provided."
             exit 0;
           ;;
        esac

     fi
     #destination does not have a duplicate file, hence move easily!

     if [ $found -eq 0 ] && [ $dupFile -eq 1 ]
     then
          echo "File found and restored to original location."
          mv $HOME"/recyclebin/"$fIname $absPath
     fi

 else
      #when file not found, append text.
      wholeFileText="$wholeFileText""$fIname:""$absPath""^"
  fi
done

#test to see if file existed or not
if [ $found -eq 1 ]
then
   echo "File does not exist in recycle bin."
   exit 1;
fi

#restore IFS
IFS=$SaveIFS


#contents of .restore.info has to be edited
if [ $found -eq 0 ] && [ $notMoved -eq 1 ]
then
   #make the file empty
   cat /dev/null > $resFileLoc
   #echo "massive text: "$wholeFileText

   #we write again

   IFS='^' read -ra lines <<< "$wholeFileText"
   for i in "${lines[@]}";
   do
        #echo "line: "$i
        echo $i >> $resFileLoc
   done
fi
IFS=$SaveIFS

#######################


  #echo $fIname
  #echo $absPath
  #
  #echo "basename:  "$bName
