#!/bin/tcsh

setenv fileList $1
setenv FileBase $2
setenv subList $3
setenv hostName $4
setenv campaign $5
setenv wheresData $6
setenv doZ $7    

if($campaign == Phys14DR) then
    setenv g_tag PHYS14_25_V2::All
    setenv gen_info True
    setenv tag_name PAT
    setenv json ""
    setenv resid ""
    setenv jec ""
else if($campaign == RunIISpring15DR74) then
    setenv g_tag MCRUN2_74_V9::All
    setenv gen_info True
    setenv tag_name PAT
    setenv json ""
#    setenv resid residual=True
    setenv resid ""
#    setenv jec jecfile=batch/jec/Summer15_25nsV2_MC
    setenv jec ""
else if($campaign == Run2015B) then
    setenv g_tag 74X_dataRun2_Prompt_v1
    setenv gen_info False
    setenv tag_name RECO
    setenv json jsonfile=batch/json/useme.json
#    setenv resid residual=True
    setenv resid ""
#    setenv jec jecfile=batch/jec/Summer15_50nsV4_DATA
    setenv jec ""
else if($campaign == Run2015C) then
    setenv g_tag 74X_dataRun2_Prompt_v1
    setenv gen_info False
    setenv tag_name RECO
    setenv json jsonfile=batch/json/useme.json
#    setenv resid residual=True
    setenv resid ""
#    setenv jec jecfile=batch/jec/Summer15_50nsV4_DATA
    setenv jec ""
endif
    
cp /batch/$hostName/x509up_u504 /tmp/x509up_u504

mkdir $TMPDIR/splitFiles/ 

@ i = 1
foreach file (`cat $fileList`)  
    cmsRun TreeMaker/TreeMaker/test/runMakeTreeFromMiniAOD_cfg.py global_tag=$g_tag geninfo=$gen_info tagname="$tag_name" doZinv=$doZ dataset="$wheresData/$file" outfile="$TMPDIR/splitFiles/$FileBase-$subList-$i" $json $jec $resid >&! $TMPDIR/$FileBase-$subList-$i.log
    @ i += 1
end

hadd $TMPDIR/$FileBase-$subList.root $TMPDIR/splitFiles/*.root

#CUStageOut $TMPDIR/$FileBase-$subList.root /nfs/data36/cms/mulholland/treeMakerSplit >&! $TMPDIR/CUStageOut.log
CUStageOut $TMPDIR/*.root /nfs/data36/cms/mulholland/treeMakerSplit >&! $TMPDIR/CUStageOut.log

cp $TMPDIR/*.log /nfs/data36/cms/mulholland/treeMakerSplitLog >&! $TMPDIR/CUStageOutLogs.log
