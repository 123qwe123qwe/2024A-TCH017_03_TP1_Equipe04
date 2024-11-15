;TP 1
;Thomas Simard, Alexandre Cirurso, Mouhcine Imaoun, Mcnestlie Lopez et Ziad Hafez

         BR      main,i 

tab:     .BLOCK  66          ;variable du tableau
tab_d:   .BLOCK  66          ;variable du tableau stockant les puissances négatives pour le calcul de la partie décimal
i:       .WORD   0           ;index i
j:       .WORD   0           ;index j
nombre:  .WORD   0           
expo:    .WORD   0           ;exposant
mant_E:  .WORD   0           ;partie entière du nombre en décimal
mant_D:  .WORD   0           ;partie décimale du nombre en décimal
c_tmp:   .WORD   0           ;valeurs temporaires
d_tmp:   .WORD   0
e_tmp:   .WORD   0
f_tmp:   .WORD   0
n:       .WORD   0           ;variables de caclculs
m:       .WORD   0
x:       .WORD   0

TAILLE:  .EQUATE 66 


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                         REMPLISSAGE DU TABLEAU
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------


main:   STRO     txt1,d      ;Execute les fonctions principales dans l'ordre dedié.

         BR      remp,i



remp:    LDA     0,i         ;Remplit le tableau (32 entrées) de chiffres binaires.
         STA     i,d
        
a_whi:   LDX     i,d         ;Lorsqu'on est au 18e index (premiere case de la mantisse), on vient mettre le 1 implicite.
         CPX     18,i
         BREQ    put_1,i

         LDX     i,d       
         CPX     TAILLE,i    ;While i<TAILLE
         BRNE    a_bdy,i
         BR      a_end,i

a_bdy:   LDX     i,d         ;Prend la valeur saisi et mets dans le tableau a l'index i
         DECI    tab,x

         BR      check_0,i   ;Verifie si nombre est binaire


a_suite: LDA     i,d         ;i++ (passe a la prochaine case)
         ADDA    2,i
         STA     i,d

         BR      a_whi,i

a_end:   BR      exp,i

check_0: LDA     tab,x       ;Verifie si la valeur saisie est 0
         CPA     0,i
         BRNE    check_1,i           
         BR      a_suite,i

check_1: LDA     tab,x       ;Verifie si la valeur saisie est 1
         CPA     1,i
         BRNE    no_bin,i    ;Si la valeur  n'est pas 0 ou 1, ce n'est pas un chiffre binaire et il a une erreur.
         BR      a_suite,i

no_bin:  STRO    txt2,d      ;Affiche le message d'erreur
         CHARO   '\n',i
         BR      main,i
         STOP

put_1:   LDX     i,d         ;Place le 1 implicite a l'index
         LDA     1,i
         STA     tab,x

         BR      a_suite,i


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                    CALCUL DE L'EXPOSANT
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;Calcul de l'exposant
exp:     LDA     16,i         ;initialise le tableau a l'index 16 (debut de l'exposant)
         STA     i,d

         LDA     1,i
         STA     c_tmp,d      ;Variable temporaire = 1, (2^0=1)

         LDA     0,i         ;Expo=0
         STA     expo,d

         BR      c_whi,i

c_whi:   LDX     i,d         ;Compare Si i=0 lorsque i=16 initialement (16 est le dernier index des 8 bits de l'exposant)
         CPX     0,i        
         BRNE    c_bdy,i     
         BR      c_end,i     ;Lorsqu'on est rendu a i=0, on a tout parcouru les cases de l'exposant et on peut aller a la fin

c_bdy:   LDX     i,d
         LDA     tab,x
         CPA     1,i         ;Si la valeur binaire est de 1 on peut additionner la puissance de 2 selon l'index respectif.
         BREQ    c_add,i
         BR      c_suite,i

c_suite: LDA     c_tmp,d    ;On multiplie par deux la valeur temporaire car on passe a la prochaine case et c'est la prochaine puissance de 2
         ASLA                ;Ex: [0] c_tmp=1 [1] c_tmp=2 [2] c_tmp=4 [3] c_tmp=8 et ainsi de suite.
         STA     c_tmp,d 

 
         LDA     i,d         ;i--
         SUBA    2,i
         STA     i,d
         BR      c_whi,i  
         
c_end:   LDA     expo,d      ;On soustrait le biais (127) a la valeur de l'exposant pour avoir sa valeur reelle.

         SUBA    127,i
         STA     expo,d  
         BR      mant,i
         STOP

c_add:   LDA     expo,d      ;On additionne la valeur temporaire qui est la puissance de 2 selon l'index a la valeur cummlé décimal.
       
         ADDA    c_tmp,d
         STA     expo,d
         BR      c_suite,i          

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                     CALCUL DE LA PARTIE ENTIERE DE LA MANTISSE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 

mant:    LDA     expo,d      ;Crée la variable n(Permet de définir séparément la partie entiere et décimale)  
         STA     n,d
         LDA     n,d              
         ASLA                ;On multiplie par deux pour qu'elle soit compatible avec le tableau qui est indexé par saut de 2
         STA     n,d

         
         LDA     1,i         ;initialise la variable de puissance de 2 a 1
         STA     d_tmp,d

         LDA     0,i         ;initialise  la partie entiere de la mantisse a 0.
         STA     mant_E,d  
 
         LDA     18,i        ;Commence a parcourir le tableau a 18+n (Partie entiere)
         ADDA    n,d
         STA     i,d

         LDA     expo,d      ;Verifie l'exposant,
         CPA     0,i
         BRGT    d_whi1,i    ;Si l'exposant est positif, on calcule la partie entiere normalement
         BREQ    mant_2,i    ;Si l'exposant est nulle, la partie entiere=1 par default.
         BRLT    mant_3,i    ;Si l'exposant est negatif, la partie entiere =0 par default.


d_whi1:  LDX     i,d         ;Continue la boucle tant que l'on n'est pas a l'index 16 (premiere case de la mantisse)
         CPX     16,i
         BRNE    d_bdy1,i
         BR      d_end,i

d_bdy1:  LDX     i,d         ;Si la valeur binaire est de 1 on peut additionner la puissance de 2 selon l'index respectif.
         LDA     tab,x      
         CPA     1,i         
         BREQ    d_add1,i
         BR      d_suite1,i         

d_suite1:LDA     d_tmp,d      ;On multiplie par deux la valeur temporaire car on passe a la prochaine case et c'est la prochaine puissance de 2
         ASLA
         STA     d_tmp,d
         
         LDA     i,d         ;i-- (passe a la prochaine case du tableau)
         SUBA    2,i
         STA     i,d

         BR      d_whi1,i

d_add1:  LDA     mant_E,d    ;Additionne la puissance actuelle a la mantisse entiere
         ADDA    d_tmp,d
         STA     mant_E,d

         BR      d_suite1,i

d_end:   BR      mant_4,i
         STOP


mant_2:  LDA     1,i         ;Si l'exposant = 0, la mantisse entiere = 1
         STA     mant_E,d 
         BR      mant_4,i
         STOP

mant_3:  LDA     0,i         ;Si l'exposant est negatif, la mantisse entiere = 0
         STA     mant_E,d
         BR      mant_5,i

         STOP

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                 CALCUL DE LA PARTIE DECIMAL DE LA MANTISSE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mant_4:  LDA     expo,i      ;Verifie si l'exposant est négatif, cela change la façon dont la mantisse est calculé.
         CPA     0,i
         BRLT    mant_5

         LDA     20,i        ;Commence a la case après la partie entière de la mantisse (20+n)
         ADDA    n,d
         STA     i,d 

         LDX     i,d
         LDA     500,i        ;La valeur temporaire e_tmp = 500, elle représente la première puissance de 2 négative, 2^-1=0.5, on l'écrit sur trois entiers donc 500
         STA     tab_d,x

e_whi:   LDX     i,d         ;Parcours case pendant qu'on n'est pas a la derniere case du tableau
         CPX     64,i
         BRNE    e_bdy,i
         BR      e_end,i

e_bdy:   LDX     i,d         ;Si la valeur de l'index=1, on peut additionner la puissance d'exposant de 2 négative selon l'index
         LDA     tab,x
         CPA     1,i

         BREQ    e_add,i
         BR      e_suite,i

e_suite: LDX     i,d

         LDA     tab_d,x     ;Mets la valeur du tableau decimal dans une variable temporaire
         STA     e_tmp,d


         LDA     i,d         ;i++ (change d'index)
         ADDA    2,i
         STA     i,d

         LDA     e_tmp,d     ;Prends la variable temporaire(la variable de la case d'avant), la divise par deux et la stock dans la nouvelle case du tableau
         ASRA                ;Dans ce programme, a chaque nouvelle indexe on obtient une nouvelle valeur des puissances negatives de 2 attitrés à e_tmp.
         STA     e_tmp,d     ;Ex: [1er chiffre de la mantisse decimal] e_tmp=500 (0.5) [2e] e_tmp=250 (0.25) [3e] e_tmp=125 (0.125) etc.

         LDX     i,d         ;Pour la nouvelle case, on mets cette valeur
         LDA     e_tmp,d
         STA     tab_d,x

         LDA     e_tmp,d 
         
         BR      e_whi,i


e_end:   BR      signe,i     
         STOP

e_add:   LDX     i,d
         LDA     mant_D,d    ;Addititionne la valeur temporaire au total de la partie décimal de la mantisse
         ADDA    tab_d,x
         STA     mant_D,d

         BR      e_suite,i   

         STOP

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                    CALCUL DE LA PARTIE DECIMAL DE LA MANTISSE, SI L'EXPOSANT EST NEGATIF
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mant_5:  LDA     500,i       ;defini la valeur temporaire intialement a 500
         STA     e_tmp,d

         LDA     expo,d      ;store la valeur de l'exposant negatif dans j
         STA     j,d

f_whi:   LDA     j,d         ;verifie si j est nulle
         CPA     -1,i
         BREQ    f_end,i
         BR      f_bdy,i

f_bdy:   LDA     e_tmp,d     ;si j!=0, on divise e_tmp par deux et on incremente j de 1.
         ASRA
         STA     e_tmp,d     ;C'est a dire, pour chaque valeur de 0 precedent le 1 implicite de la mantisse, on va diviser la valeur temporaire par deux. 

         LDA     j,d         ;j++
         ADDA    1,i
         STA     j,d

         BR      f_whi,i

f_end:   LDA     18,i        ;On commence l'analyse de la mantisse (incluant le 1 implicite) une fois que la valeur temporaire est deja divise selon les puissances négatives
         STA     i,d         ;Pour cela on initialise l'index à 18 (case ou débute la mantisse(incluant le 1 implicite)

         LDX     i,d        
         LDA     e_tmp,d
         STA     tab_d,x

         BR      e_whi,i

         STOP



;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                        CALCUL DU SIGNE DU NOMBRE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------



signe:   LDA     0,i         ;Verifie le premier bit du nombre, si = 1, le chiffre est negatif
         STA     i,d
         
         LDX     i,d
         LDA     tab,x
         CPA     1,i

         BREQ    neg,i
         BR      print,i

         STOP

neg:     LDA     mant_E,d    ;On fait un complement a deux sur la partie entier de la mantisse pour le rendre negatif.
         NEGA
         STA     mant_E,d
         BR      print,i
         STOP

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                               AFFICHAGE DES MESSAGES ET VALEURS FINAUX
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print:   LDA     2,i         ;initialise le tableau a la deuxieme case
         STA     i,d

         CHARO   '\n',i
         STRO    txt3,d

         BR      p_whi,i

p_whi:   LDX     i,d         ;imprime les case 2-9 pour montrer l'exposant en binaire             
         CPX     18,i
         BRNE    p_bdy,i
         BR      p_suite1,i

p_bdy:   LDX     i,d
         DECO    tab,x
         
         LDA     i,d         ;i++
         ADDA    2,i
         STA     i,d

         BR      p_whi,i

         STOP

p_suite1:CHARO   '\n',i      ;affiche un ,message ansi que l'exposant en decimal
         STRO    txt4,d
         DECO    expo,d

         BR      p_suite2,i  
                             

p_suite2:CHARO   '\n',i      ;Affiche un message et la mantisse avant l'exposant
         STRO    txt6,d
         LDA     20,i        
         STA     i,d
  
;       
p_whi2:  LDX     i,d         ;Commence a l'index 20 et parcours les case jusqu'a la fin du tableau
         CPX     TAILLE,i    ; a chaque index, on imprime la  valeur
         BREQ    p_suite4,i  ;On affiche ainsi la mantisse originalement avant d'appliqué l'exposant
         BR      p_bdy2,i

p_bdy2:  LDX     i,d
         DECO    tab,x
         
         LDA     i,d         ;i++
         ADDA    2,i
         STA     i,d
          
         BR      p_whi2,i

p_suite4:CHARO   '\n',i      ;affiche un message et la mantisse après l'exposant
         STRO    txt7,d

         LDA     expo,d      ;Verifie si l'exposant est positif, nulle ou négatif
         CPA     0,i         ;Dépendément du signe, la mantisse n'est pas affiché de la même façon.
         BREQ    p_nul,i
         BRLT    p_neg,i 
         BRGT    p_pos,i 

;---------------------------------------------------------------------------------------------------------------------------------------------------------

p_nul:   LDA     20,i        ;Si l'exposant est nul, commence à l'index 20 (mantisse sans le 1 implicite)
         STA     i,d

         CHARO   '1',i       ;On affiche "1." Pour afficher le 1 implicite avant d'afficher la mantisse
         CHARO   '.',i 
         
p_whi3:  LDX     i,d         ;On fait une boucle jusqu'a la fin du tableau
         CPX     TAILLE,i
         BREQ    p_suite3,i
         BR      p_bdy3,i

p_bdy3:  LDX     i,d         ;On imprime la valeur dans l'index pour chaque index
         DECO    tab,x       ;La mantisse après le 1 implicite est ainsi affiché au complet
                             ; On observe ainsi "1.(la mantisse)"
         LDA     i,d         ;i++
         ADDA    2,i
         STA     i,d
          
         BR      p_whi3,i 

;---------------------------------------------------------------------------------------------------------------------------------------------------------

p_neg:   CHARO   '0',i       ;Si l'exposant est négatif, on commence par afficher "0."
         CHARO   '.',i       ;Ici, puisque l'exposant est négatif, on veut savoir combien de zéro il faut afficher avant d'afficher la mantisse.
                             ;Quand on multiplie par un exposant négatif, on décale la virgule vers la gauche, donc on doit mettre des 0 a gauche de la mantisse dépendemment de la grandeur de l'exposant.
         LDA     expo,d      ;On charge l'exposant et le store dans m pour ne pas modifier sa valeur original
         STA     m,d

p_whi4:  LDA     m,d         ;On fait une boucle avec m jusqu'à m=-1
         CPA     -1,i        ;On fait =-1 plutôt que =0 car nous avons déjà un 0. d'affiché.
         
         BREQ    p_end4,i
         BR      p_bdy4,i

p_bdy4:  CHARO   '0',i       ;Pour chaque itération, on affiche un 0.
         LDA     m,d         ;m++
         ADDA    1,i
         STA     m,d

         BR      p_whi4,i    ;De même, pour chaque valeur de l'exposant négatif, on affiche un 0.

p_end4:  LDA     18,i        ;On charge 18 dans l'index pour afficher la mantisse avec son 1 implicite.
         STA     i,d

         BR      p_whi3,i    ;p_whi3 affiche la mantisse en parcourant le tableau

;---------------------------------------------------------------------------------------------------------------------------------------------------------

p_pos:   LDA     18,i        ;Lorsque l'exposant est positif, on affiche la première partie dans la mantisse, la virgule et puis la deuxième partie de la mantisse
         STA     i,d

         LDA     i,d         ;Defini ou est la virgule, 18 + n, (n est expliqué plus tôt dans la fonction)
         ADDA    n,d
         ADDA    2,i
         STA     x,d         ;On ajoute 2 et on store dans x
                             ;X est l'index ou qu'on doit arrêter d'afficher car il est l'index qui divise la mantisse en deux partie.
p_whi5:  LDX     i,d         ;On compare l'index 18(mantisse avec 1 implicite) à x et on fait une boucle
         CPX     x,d

         BREQ    p_pos2,i
         BR      p_bdy5,i

p_bdy5:  LDX     i,d         ;Pour chaque index, on affiche la valeur
         DECO    tab,x

         LDA     i,d         ;i++
         ADDA    2,i
         STA     i,d

         BR      p_whi5,i

p_pos2:  CHARO   '.',i       ;Après avoir afficher toute la première partie de la mantisse, un affiche le point/la virgule.

p_whi6:  LDX     i,d         ;On compare maintenent i à la taille maximum du tableau pour afficher la partie restante de la mantisse en faisant une boucle
         CPX     TAILLE,i    

         BREQ    p_suite3,i
         BR      p_bdy6,i

p_bdy6:  LDX     i,d         ;pour chaque index, on affiche la valeur
         DECO    tab,x

         LDA     i,d         ;i++
         ADDA    2,i
         STA     i,d

         BR      p_whi6,i

         STOP


;---------------------------------------------------------------------------------------------------------------------------------------------------------

p_suite3:CHARO   '\n',i      ;Affiche un message et le nombre complet en decimal
         STRO    txt5,d
         
         DECO    mant_E,d    ;Affiche la partie entière du nombre en décimal
         CHARO    '.',i      ;Affiche un point
         LDA     mant_D,d    ;On vérifie si la partie décimal=0
         CPA     0,i
         BREQ    add_0,i

         LDA     mant_D,d    
         CPA     100,i       ;si la partie decimale est plus petite que 100, on rajoute un 0 en avant
         BRLT    put1_0,i

p_suite6:LDA     mant_D,d
         CPA     10,i        ;si la partie decimale est plus petite que 10 on rajoute deux 0 en avant
         BRLT    put2_0,i    ;Pas besoin de le faire pour 3 0 puisque la valeur de la partie decimal sera deja de 0 si elle est trop petite, on ne veut donc pas afficher accidentellement 4 0.

         
p_suite5:DECO    mant_D,d    ;affiche la partie décimal de la mantisse

         BR END,i

add_0:   CHARO   '0',i       ;si partie décimal=0, on affiche deux zéros supplémentaires pour avoir la précision décimal à trois chiffres.
         CHARO   '0',i

         BR p_suite5,i

put1_0:  CHARO   '0',i       ;affiche un 0
         BR      p_suite6,i 
         STOP

put2_0:  CHARO   '0',i       ; affiche un 0
         BR      p_suite5,i 
         STOP

END:     STOP    ;Fin du programme

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;                                                                 MESSAGES UTILISES DANS LE PROGRAMME
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

txt1:    .ASCII"Saisir un nombre binaire de 32 bits:\n\x00"
         STOP
txt2:    .ASCII"ERREUR: la valeur saisie n'est pas binaire!\n\x00"
         STOP
txt3:    .ASCII"L'exposant en binaire est: \x00"
         STOP
txt4:    .ASCII"L'exposant en décimal après le biais est: \x00"
         STOP
txt5:    .ASCII"Le nombre complet en décimal est: \x00"
         STOP
txt6:    .ASCII"La mantisse avant l'exposant est: 1.\x00"
         STOP
txt7:    .ASCII"La mantisse apres l'exposant est: \x00"
         STOP


.END   
