% Load images.
I{1} = iread('A1/dataset/building1.jpg');
I{2} = iread('A1/dataset/building2.jpg');
I{3} = iread('A1/dataset/building3.jpg');
I{4} = iread('A1/dataset/building4.jpg');
I{5} = iread('A1/dataset/building5.jpg');
%% Imagem 1 e 2
I{1}=rgb2gray(I{1});
I{2}=rgb2gray(I{2});

sf=isurf(I{1},'extended','nfeat',200);
sf2=isurf(I{2},'extended','nfeat',200);

[m2,C2]=sf2.match(sf,'top',30);
trans2=m2.ransac(@homography,10,'maxTrials',1e4);

trans1=eye(3);
trans2=trans2*trans1;

out2=homwarp(trans2,I{2},'full');
figure
imshow(out2);

figure
idisp({I{1},I{2}})
m2.plot()
%% Imagem 2 e 3

I{3}=rgb2gray(I{3});

sf2=isurf(I{2},'extended');
sf3=isurf(I{3},'extended');

m3=sf3.match(sf2,'top',Inf)
trans3=m3.ransac(@homography,10,'maxTrials',1e4);

trans3=trans3*trans2

out3=homwarp(trans3,I{3},'full');
figure
imshow(out3);


%% Imagem 3 e 4

I{4}=rgb2gray(I{4});

sf3=isurf(I{3},'extended');
sf4=isurf(I{4},'extended');

m4=sf4.match(sf3,'top',Inf)
trans4=m4.ransac(@homography,10,'maxTrials',1e4);

trans4=trans4*trans3

out4=homwarp(trans4,I{4},'full');
figure
imshow(out4);
%% Imagem 4 e 5

I{5}=rgb2gray(I{5});

sf4=isurf(I{4},'extended');
sf5=isurf(I{5},'extended');

m5=sf5.match(sf4,'top',Inf)
trans5=m5.ransac(@homography,10,'maxTrials',1e4);

trans5=trans5*trans4

out5=homwarp(trans5,I{5},'full');
figure
imshow(out5);

%% Criar panorama - método Peter Coker
panorama = zeros([800 2400 3], 'like',im);



%% Criar panorama
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
'MaskSource', 'Input port');
xLimits =[-600 1650]
yLimits =[-160 650]
% Create a 2-D spatial reference object defining the size of the panorama.
panoramaView = imref2d([800 2400], xLimits, yLimits);
panorama = zeros([800 2400 3], 'like',im);
% Transform I into the panorama
im_gray=readimage(buildingScene,1);
warpedImage=homwarp(trans1,im_gray);
im2_gray=readimage(buildingScene,2);
warpedImage2=homwarp(trans2,im2_gray);
im2_gray=readimage(buildingScene,3);
warpedImage3=homwarp(trans3,im_gray);
im4_gray=readimage(buildingScene,4);
warpedImage4=homwarp(trans4,im4_gray);
im5_gray=readimage(buildingScene,5);
warpedImage5=homwarp(trans5,im5_gray);
%%
% Overlay the warpedImage onto the panorama.

warpedImage = uint8(255 * mat2gray(warpedImage));
warpedImage2= uint8(255 * mat2gray(warpedImage2));
warpedImage3= uint8(255 * mat2gray(warpedImage3));
warpedImage4= uint8(255 * mat2gray(warpedImage4));
warpedImage5= uint8(255 * mat2gray(warpedImage5));

panorama=step(blender, panorama,warpedImage,warpedImage(:,:,1));
panorama=step(blender, panorama,warpedImage2,warpedImage2(:,:,1));
panorama=step(blender, panorama,warpedImage3,warpedImage3(:,:,1));
panorama=step(blender, panorama,warpedImage4,warpedImage4(:,:,1));
panorama=step(blender, panorama,warpedImage5,warpedImage5(:,:,1));

figure
imshow(panorama)
figure
imshow(out2)