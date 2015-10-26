#!/bin/tcsh

setenv fileList $1
setenv FileBase $2
setenv subList $3
setenv hostName $4
setenv campaign $5
setenv wheresData $6
setenv doZ $7    

if($campaign == Phys14DR) then
    setenv scenario Phys14
else if($campaign == RunIISpring15DR74) then
    setenv scenario Spring15
else if($campaign == Run2015B) then
    setenv scenario re2015B
else if($campaign == Run2015C) then
    setenv scenario 2015C
else if($campaign == Run2015D) then
    setenv scenario 2015D
endif
    
cp /batch/$hostName/x509up_u504 /tmp/x509up_u504

mkdir $TMPDIR/splitFiles/ 

@ i = 1
foreach file (`cat $fileList`)  
    cmsRun TreeMaker/Production/test/runMakeTreeFromMiniAOD_cfg.py lostlepton=false hadtau=false QCD=false doZinv=$doZ scenario=$scenario dataset="$wheresData/$file" outfile="$TMPDIR/splitFiles/$FileBase-$subList-$i" >&! $TMPDIR/$FileBase-$subList-$i.log
    @ i += 1
end

hadd $TMPDIR/$FileBase-$subList.root $TMPDIR/splitFiles/*.root

#CUStageOut $TMPDIR/$FileBase-$subList.root /nfs/data36/cms/mulholland/treeMakerSplit >&! $TMPDIR/CUStageOut.log
CUStageOut $TMPDIR/*.root /nfs/data36/cms/mulholland/treeMakerSplit >&! $TMPDIR/CUStageOut.log

cp $TMPDIR/*.log /nfs/data36/cms/mulholland/treeMakerSplitLog >&! $TMPDIR/CUStageOutLogs.log
