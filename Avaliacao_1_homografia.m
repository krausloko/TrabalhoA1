%%---------------------------------
% Copyright (C) 2017-2018, by Marcelo R. Petry
% This file is distributed under the MIT license
% 
% Copyright (C) 2017-2018, by Marcelo R. Petry
% Este arquivo é distribuido sob a licença MIT
%%---------------------------------

%%---------------------------------
% BLU3040 - Visao Computacional em Robotica
% Avaliacao 1 - Homografia: Imagens panoramicas
% Requisitos:
%   MATLAB
%   Machine Vision Toolbox 
%       P.I. Corke, “Robotics, Vision & Control”, Springer 2011, ISBN 978-3-642-20143-1.
%       http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox
%%---------------------------------

%%---------------------------------
%Objetivo 
%Nas aulas anteriores aprendemos que se a homografia entre duas
%imagens e conhecida podemos projetar uma das imagens no mesmo referencial
%que a outra. As imagens continham um plano, e somente a parte planar era
%alinhada de maneira correta. Acontece que se capturarmos uma imagem de uma
%cena, rotacionarmos a câmera e tirarmos uma segunda imagem da mesma cena
%as duas imagens também estarão relacionadas por uma matriz de homografia.
%Desta forma, voce pode instalar sua câmera em um e tirar uma fotografia.
%Girar a câmera sob o eixo vertical e tirar outra fotografia. Estas duas
%imagens completamente arbitrarias estão relacionadas por homografia, e por
%isso compartilham regiões que podem ser alinhadas e combinadas para criar
%uma fotografia panoramica. Neste trabalho o objetivo é desenvolver um
%algoritmo em MATLAB que seja capaz de ler as imagens do dataset fornecido,
%corrigir a perspectiva destas imagens e criar uma imagem panorâmica.
%%---------------------------------

%%---------------------------------
% Dataset
% O dataset padrão para testes contém cinco imagens coloridas (640x480) de
% um edifício e esta disponivel na pasta /dataset/
%%---------------------------------


%Desenvolva seu codigo aqui

%Configuração MATLAB - opengl('save','software')
clear all
clc
close all
%% Parte 1 
%Usuario inserir numero de imagens
%num=input('Fornecer o número de imagens do conjunto: ')
%Usuario inserior caminho para a pasta de imagens - neste caso dataset
caminho=input('Digite o caminho da pasta:','s')
pasta=fullfile(caminho);
conjunto=imageDatastore(pasta);
%Numero de Imagens
num=length(conjunto.Files)
referencia=input('Digite a imagem de referencia: 0 - Imagem Extremo | 1 - Imagem Cental:  ')
%% Parte 2 -Carregar imagens

for i=1:num
    %Carregar imagem
     I{i}=iread(conjunto.Files{i,1});
end

%% Parte 3 - Encontrar features e matches, calcular homografia e transformação. 

for i=1:num
    
    if(i==1)
        %Inicializar variavel features
        features{i}=isurf(I{i},'extended');
        Trans{i}=eye(3);
    end
    
    if(i~=1)
    %Encontar features
    featuresAnt=features{i-1};
    features{i}=isurf(I{i},'extended');
    
    %Encontrar matches
    [m{i},C{i}]=features{i}.match(featuresAnt,'top',40);  
    %Aplica para otimizar
    Trans{i}=m{i}.ransac(@homography,1,'maxTrials',1e4);
    %Como trans(i-1) já esta relacionada com a imagem anterior não é
    %necessario multiplicar por todas a matriz até chegar na imagem de
    %referência
    Trans{i}=Trans{i}*Trans{i-1};
    end
    
end

%% Testar Homografia: Teste com segunda imagem
out=homwarp( Trans{2},I{2},'full');
figure
imshow(out);

figure
idisp({I{1},I{2}})
m{2}.plot()
%% Parte 4 - Aplicar transformações calculadas nas respectivas imagens
%Variável para armazenar os tamanhos das imagens após transformação
tamanho=zeros(length(I),2);

for i=1:num

    %Se referencia for imagem central recalcular transfomações
    if(referencia==1)
        alguma=inv(Trans{3})*eye(3);
        %Calcular novamente as transformações       
        Trans{1}=alguma*Trans{1};
        Trans{2}=alguma*Trans{2};
        Trans{3}=alguma*Trans{3};
        Trans{4}=alguma*Trans{4};
        Trans{5}=alguma*Trans{5};
    end
    
    %Aplicar transformação nas imagens | guardar valor do offset
    %[out,offs] = homwarp(H, im, options) - offs is the offset of the warped tile
    %out with respect to the origin of im.  
    [warpedImage{i},offset(i,:)]=homwarp(Trans{i},I{i},'full','extrapval',0);
    k=size(warpedImage{i});
    tamanho(i,:)=k(1,1:2);
end

%% Testar Transformações - Testar com última imagem já que é a mais deformada quando
% a referência é a primeira imagem
figure
idisp(warpedImage{5});
%% Parte 5 - Criar panorama:Método Peter Coker

for i=1:num
  % Criacao de mascaras - criar retângulo do tamanho da imagem transformada
    mascara{i} = rgb2gray(warpedImage{i}) == 0;
end

% Definicao das dimensoes do panorama
%V - altura | U - comprimento
% u=3000;
% v=1200;
%Utilizar ABS porque offset retorna valores negativos neste caso 
% error - pattern falls off right edge
u=abs(offset(1,1))+3*max(tamanho(:,2))+offset(num,1);
v=max(tamanho(:,1))+max(abs(offset(:,2)));

%Criar Imagem com as dimensões encontradas
panorama = zeros(v,u,3);

%Calculo da posicao da primeira imagem no panorama
refU=abs(min(offset(:,1)));
refV=abs(min(offset(:,2)))+1;

%%  Montagem do panorama
for i=1:num
    %Criar mascara com dimensoes do panorama
    mascara_panorama= ones(v,u,3);
    %Colar na mascara quadrado com tamanho da imagem transformada
    mascara_panorama= ipaste(mascara_panorama,mascara{i},[refU+offset(i,1)+1,refV+offset(i,2)]);
    mascara_panorama2{i}=mascara_panorama;
    %Deixar espaço livre no panorama para colar a imagem
    panorama=panorama.*mascara_panorama;
    panorama=ipaste(panorama,warpedImage{i},[refU+offset(i,1)+1,refV+offset(i,2)],'add');
    end

figure
idisp(panorama);