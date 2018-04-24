# Trabalho A1 - Homografia

Primeiro Trabalho da disciplina BLU3040 - Visao Computacional em Robótica, UFSC - Campus Blumenau

## Função:
O algoritmo desenvolvido é capaz de criar uma imagem panorâmica a partir de um conjunto de imagens.  ![panorama_final](https://user-images.githubusercontent.com/35512686/39162626-d38fc004-474c-11e8-82f8-36487c501ba8.jpg)

## Quick start:
<p>1- Fazer download completo do repositório.<p>
<p>2- Executar o arquivo 'Avaliacao_1_homografia.m'.<p>
<p>3- Inserir o caminho para a pasta com conjunto de imagens (dataset) 'Avaliacao_1_homografia.m'.<p>
<p>4- Optar por uma das referências possíveis: 0 para imagem do canto ou 1 para imagem central.<p>
<p>5- Abrir as janelas para ver o panorama.<p>

## How it works
**Parte 1: Carregar imagens**  
As imagens do dataset são carregadas na celula I  
**Parte 2: Passar imagens para escala de cinza (algumas funções fazem isto de forma automática)**  
 Transformar as imagens coloridas para escala de cinza  
**Parte 3: Verificar tamanho do conjunto de imagens, encontrar features, encontrar matches, calcular homografia otimizada**  
 Verificar o tamanho de I - quantas imagens existem no conjunto  
 Aplicar função _isurf_ para encontrar features da imagem I(i)  
 Comparar features das Imagens I(i) e I(i-1) para encontrar matches  
 Utilizar função iterativa _ransac_ para calcular a melhor homografia que relaciona I(i) e I(i-1)   
 Calcular homografia global para relacionar I(i) com I(1).  
**Parte 4: Testar Homografia**  
 Aplicar homografia para verficar resultado  
**Parte 5: Carregar imagens novamente**  
 Carregar imagens coloridas novamente  
**Parte 6: Construir Panorama**  
 Construir panorama com as imagens transformadas  


Para ver o embasamento teórico e explicação detalhada do código basta ler o arquivo 'Relatório A1 - Visão Computacional.pdf'

## License:
This toolbox is under the MIT License: http://opensource.org/licenses/MIT.
