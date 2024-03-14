function obj = getPrep(obj)
%GETPREP Prepare the MRI and post CT images
if strcmp(obj.CoregMethod,'spm_coreg')  
    MRI = spm_vol(obj.Anat);
    postCT = spm_vol(obj.PostCT);
    % Move the CT to the 3DT1 space: spm evaluate
    x = spm_coreg(MRI,postCT);
    M  = spm_matrix(x);
    MM = zeros(4,4,numel(postCT));
    MM = spm_get_space(postCT.fname);
    spm_get_space(postCT.fname, M\MM(:,:));
else 
    fprintf('\n')
    fprintf('%-40s %30s\n','ANTS: ants.registration',spm('time'));
    fprintf('%s\n', repmat('=', 1, 72));
    ants = py.importlib.import_module('ants');
    MRI = ants.image_read(obj.Anat);
    postCT = ants.image_read(obj.PostCT);
    mytx = ants.registration(fixed=MRI,moving=postCT,type_of_transform='Rigid');
    ants.image_write(mytx{'warpedmovout'}, obj.PostCT)    
    fprintf('%-40s: %30s\n','Completed',spm('time'));
end

% Display the aligned MRI and CT images
MRIVolume = medicalVolume(obj.Anat);
CTVolume = medicalVolume(obj.PostCT);
MRIVoxels = MRIVolume.Voxels;
CTVoxels = CTVolume.Voxels;
centerMRI  = MRIVolume.VolumeGeometry.VolumeSize/2;
centerCT = CTVolume.VolumeGeometry.VolumeSize/2;
figure('Name','Registed MRI and CT images');
subplot(131);
imshowpair(squeeze(CTVoxels(:,:,centerCT(3))), squeeze(MRIVoxels(:,:,centerMRI(3))))
axis off
subplot(132);
imshowpair(squeeze(CTVoxels(:,centerCT(2),:)), squeeze(MRIVoxels(:,centerMRI(2),:)))
axis off
subplot(133);
imshowpair(squeeze(CTVoxels(centerCT(1),:,:)), squeeze(MRIVoxels(centerMRI(1),:,:)))
axis off

% Reslice the MRI to the CT
P = {obj.PostCT;obj.Anat};
% Parameters
flags.mean = false;
flags.which = 1;
spm_reslice(P,flags)

% Segment the MRI
load('SegmentJob.mat')

% 1) Change the target volume
TargVol = dir('r*.nii');
job.channel.vols = {[pwd, filesep, TargVol.name]};
% 2) Change the TPM volume location when used
spmPath = fileparts(which('spm.m'));

for i = 1:6
    job.tissue(i).tpm = {[spmPath, filesep, 'tpm', filesep, 'TPM.nii,',num2str(i)]};
end

spm_preproc_run(job)


% create brain mask using segmented images
% Read the matrix
GreyF = dir('c1*.nii');
GreyM = niftiinfo(GreyF.name);

WhiteF = dir('c2*.nii');
WhiteM = niftiinfo(WhiteF.name);

CSFF = dir('c3*.nii');
CSF  = niftiinfo(CSFF.name);

GrayMat = niftiread(GreyM);
WhiteMat = niftiread(WhiteM);
CSFMat   = niftiread(CSF);
% Combine and fill the ventricles and create binary mask
GrayMsk  = GrayMat  > 0;
WhiteMsk = WhiteMat > 0;
CSFMsk   = CSFMat > 0;

GWCMsk = or(GrayMsk,or(WhiteMsk,CSFMsk));
% GWCMsk = or(GrayMsk,WhiteMsk);
% GWCMsk = WhiteMsk;

GWCMskFill = imfill(GWCMsk,'holes');
GSCMskFillInfo = GreyM;
GSCMskFillInfo.Filename = [];
GSCMskFillInfo.Filesize = [];
GSCMskFillInfo.Description = [];
niftiwrite(uint8(GWCMskFill),'BrainMask.nii',GSCMskFillInfo)

end
