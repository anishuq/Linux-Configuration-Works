#!/bin/bash
export PATH="$HOME/project:$PATH";
################################################################
#Set global var to 0 or true based on getopts choice
Ioption=1
Voption=1
IVoption=1
VIoption=1
NOopt=1
wildCard=1

################################################################
#getopts code
multiOpt=""
while getopts :iv opt
do
   case "$opt" in
      i)
         Ioption=0;
         multiOpt=$multiOpt"i"
         ;;
      v)
         Voption=0;
         multiOpt=$multiOpt"v"
         ;;
     *) echo "unknown option provided"
        exit 1;
        ;;
  esac
done

if [ $OPTIND -eq 1 ]
then
   #echo "No option is provided"
   NOopt=0;
fi
shift $[ $OPTIND - 1 ]


if [ "$multiOpt" = "iv" ]
then
   IVoption=0
   Ioption=1
   Voption=1
elif [ "$multiOpt" = "vi" ]
then
   VIoption=0
   Ioption=1
   Voption=1
fi

################################################################


function srcFileDel(){
  if [ $srcFileLoc = $1 ]
  then
     echo 24;
  else
    echo 0
  fi
}


################################################################
srcFileLoc=$(realpath $0);


#create a hidden file
touch $HOME"/"".restore.info"


#create recycle bin with all permission
mkdir -m 777 "$HOME/recyclebin" > /dev/null 2>&1;
if [ $? -eq 0 ]
then
   echo "Recycle Bin created successfully."
fi


#read arguments
if [ $# -lt 1 ]
then
   echo "No Filename provided"
   exit 21
fi



fn=''

for fn in $@
do
  abspath=$(realpath $fn)
  dName=$(dirname $abspath);
  bName=$(basename $abspath);


  absFilePath=$dName"/"$bName
  #echo "ccc   "$absFilePath

  isSFile=$(srcFileDel $absFilePath);

  if [ $isSFile -eq 24 ]
  then
      echo "Attempting to delete recycle - opeartion aborted.";
      exit 1;
   fi

  #test for file
  if [ -f $absFilePath ] && [ ! -d $absFilePath ]
  then
     #echo "A valid file"
     #move to recycle bin
     fileInode=$(ls -i $absFilePath)
     #echo "vvvv  "$fileInode

     iNode=$(echo $fileInode | tr -dc '0-9')
     #echo $iNode
     fname=$(basename $absFilePath)
     #echo $fname
     recFileName=$fname"_"$iNode
     #echo $recFileName
     ##################################################
     #We can delete, but now check for options


##########################################################################################


     #i OPTION

     #$choice=''
     if [ $Ioption -eq 0 ] && [ $Voption -eq 1 ] && [ $IVoption -eq 1 ] && [ $VIoption -eq 1 ]
     then
          echo -n "recycle: remove regular file $fname? Press Y or N."

          read choice < /dev/tty

          initial="$(echo $choice | head -c 1)"

          case $initial in
                y|Y)
                    mv $absFilePath $HOME"/recyclebin/$recFileName"
                    if [ $? -eq 0 ]
                    then
                        echo "$recFileName"":""$absFilePath">>$HOME"/.restore.info"
                    else
                        echo "File Cannot be deleted"
                    fi
                ;;
                n|N)
                   echo "File not deleted due to user choice."
                ;;
                *)
                   echo "invalid argument provided."
                ;;
          esac

     fi
###########################################################################################
     #-v OPTION

     if [ $Ioption -eq 1 ] && [ $Voption -eq 0 ] && [ $IVoption -eq 1 ] && [ $VIoption -eq 1 ]
     then
         mv $absFilePath $HOME"/recyclebin/$recFileName"
         if [ $? -eq 0 ]
         then
             echo "File $fname deleted to recycle bin"
             echo "$recFileName"":""$absFilePath">>$HOME"/.restore.info"
         else
             echo "File Cannot be deleted"
         fi
     fi
############################################################################################
     #-iv OR -vi option
     if [ $IVoption -eq 0 ] || [ $VIoption -eq 0 ]
     then
          echo -n "recycle: remove regular file $fname? Press Y or N."

          read choice < /dev/tty

          initial="$(echo $choice | head -c 1)"


          case $initial in
                y|Y)
                    mv $absFilePath $HOME"/recyclebin/$recFileName"
                    if [ $? -eq 0 ]
                    then
                        echo "File $fname deleted to recycle bin"
                        echo "$recFileName"":""$absFilePath">>$HOME"/.restore.info"
                    else
                        echo "File Cannot be deleted"
                    fi
                ;;
                n|N)
                   echo "File not deleted due to user choice."
                ;;
                *)
                   echo "invalid argument provided."
                ;;
          esac

     fi
###########################################################################################
    #No options provided
    if [ $NOopt -eq 0 ]
    then
        mv $absFilePath $HOME"/recyclebin/$recFileName"
        if [ $? -eq 0 ]
        then
            echo "$recFileName"":""$absFilePath">>$HOME"/.restore.info"
        else
            echo "File Cannot be deleted"
        fi
    fi
############################################################################################
  else
     if [ -d $absFilePath ]
     then
        echo "its a directory and cannot be deleted"
        exit 1
     else
        echo "File does not exist."
        exit 1
     fi
  fi

done
