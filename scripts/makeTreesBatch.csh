#!/bin/tcsh

setenv TAG1 $1
setenv TAG2 $2
setenv TAG3 $3
setenv perDeploy $4
setenv doZ $5    

setenv FileList `ls batch/text/fileLists/*.txt | grep $TAG1 | grep $TAG2 | grep $TAG3`

setenv dataType `head -1 $FileList | sed 's/\/store\///' | sed -e 's/\/.*//'`
setenv campaign `head -1 $FileList | sed 's/\/store\///' | sed -e 's/'$dataType'\///' | sed -e 's/\/.*//'`
setenv sample `head -1 $FileList | sed 's/store\///' | sed -e 's/'$dataType'\///' | sed -e 's/\/'$campaign'\///' | sed -e 's/\/.*//'`
setenv PU_Reco  `head -1 $FileList | sed 's/store\///' | sed -e 's/'$dataType'\///' | sed -e 's/\/'$campaign'\///' | sed -e 's/'$sample'\///' | sed -e 's/MINIAOD//' | sed -e 's/SIM//' | sed -e 's/\///' | sed -e 's/\/.*//'`

echo $dataType
echo $campaign
echo $sample    
echo $PU_Reco    

setenv HOST `hostname | sed -e 's/.colorado.edu//'`

#only checks if there is a root file in path
#should check for entire dataset in hadoop
#need to update
setenv localCheck `find /mnt/hadoop/store/$dataType/$campaign/$sample/*/$PU_Reco/ -name '*.root' | tail -1`
    
if ( $FileList == "" ) then
 echo "Check your tags: FileList = null"
 exit( 1 ) 
else if ( $localCheck == "") then
 echo "*********************************"
 echo "dataset not found in hadoop, using XrootD to get data"
 setenv findData 'root://cmsxrootd.fnal.gov'
else
 echo "*********************************"
 echo "dataset found in hadoop, running on local data"
 setenv findData 'file:/mnt/hadoop'
endif

setenv deployScript ./batch/scripts/subDeploy.csh
    
setenv FileBase `echo $FileList | sed 's/batch\/text\/fileL.*\///' | sed 's/.txt//'`
echo $FileBase
    
echo "*********************************"
echo "running on "$FileBase

echo "*********************************"
echo "Removing old text files and trees"

rm -f batch/text/fileLists/subLists/*$FileBase*

rm -f treeMakerSplit/*$FileBase*
rm -f treeMakerSplitLog/*$FileBase*

split -d -a 3 -l $perDeploy $FileList batch/text/fileLists/subLists/$FileBase

setenv filesToRunOn `cat $FileList | wc -l`
setenv numJobs `ls batch/text/fileLists/subLists/$FileBase* | wc -l`

echo "*********************************"
echo "Will submit "$numJobs" jobs running on "$filesToRunOn" files"
sleep 1
echo "*********************************"
echo "Submitting jobs..."
sleep 1
@ i = 1
foreach fileSubList ( `ls batch/text/fileLists/subLists/$FileBase*` )
    setenv QNAMEPREFIX `echo $FileBase | cut -c-5`
    setenv QNAME $QNAMEPREFIX-$i
    Qsub -e -l lnxfarm -N $QNAME -o treeMakerSplitLog/QSub$FileBase-$i.log $deployScript $fileSubList $FileBase $i $HOST $campaign $findData $doZ
    @ i += 1
end
