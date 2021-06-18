function obj = getPrep(obj)
%GETPREP Summary of this function goes here
%   Detailed explanation goes here
% Move the CT to the 3DT1 space: spm evaluate
MRI = spm_vol('3DT1.nii');
postCT = spm_vol('postCT.nii');
x = spm_coreg(MRI,postCT);
 M  = spm_matrix(x);
MM = zeros(4,4,numel(postCT));

MM = spm_get_space(postCT.fname);

spm_get_space(postCT.fname, M\MM(:,:));
% Done
% Coregister and reslice the MRI to the CT

% Segment the MRI

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


GWCMskFill = imfill(GWCMsk,'holes');
GSCMskFillInfo = GreyM;
GSCMskFillInfo.Filename = [];
GSCMskFillInfo.Filesize = [];
GSCMskFillInfo.Description = [];
niftiwrite(uint8(GWCMskFill),'BrainMask.nii',GSCMskFillInfo)

end

