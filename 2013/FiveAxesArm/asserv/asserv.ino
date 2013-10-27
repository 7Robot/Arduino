/************************************************************************************/
/* L'objectif de ce programme est d'asservir en angles chacun des 5 moteurs du bras */
/************************************************************************************/

/*
L'algorithme se base sur le principe suivant :
Chaque moteur peut avoir 2 états différents :
  1) commandé par appui sur bouton
  2) asservi en angle
Voilà le principe de l'algorithme : 

######################################################################################
######################################################################################
#############################      ALGORITHME     ####################################
  
Pour chaque moteur :
  si le moteur est asservi en angle
    ecart = getEcart(moteur)
    commande = getCommande(ecart)
    commanderMoteur(moteur, commande)
  sinon (moteur commandé par bouton)
    commande = getCommandeBouton(moteur)
    commanderMoteur(moteur, commande)
    maj les valeurs de consignes angulaire avec la position actuelle

#############################    FIN ALGORITHME     ##################################
######################################################################################
######################################################################################

où commande est un entier dans [[-255 ; 255]]
et commanderMoteur(moteur,commande) effectue les différentes actions suivantes :
    renvoi un PWM proportionnel à |commande|
    active ou non la pin de sens suivant le signe de commande
*/
/*
######################################################################################
######################################################################################
#############################      VARIABLES      ####################################
*/
// pin des moteurs
const byte pinMoteur[5] = {3,5,6,9,10};

// sens des moteurs
const byte pinSensMoteur[5] = {2,4,7,8,12};
boolean sensMoteur[5] = {0,0,0,0,0};

// pota des moteurs
const byte pinPotaMoteur[5] = {A0,A1,A2,A3,A4};
int potaMoteur[5] = {0,0,0,0,0};

// position et consigne angulaire des moteurs
float angleMoteur[5] = {0,0,0,0,0};
float consigneAngleMoteur[5] = {0,0,0,0,0};

// etats des moteurs (0 = asservi et 1 = commandé)
boolean etatMoteur[5] = {0,0,0,0,0};

// communication serie
const int baudRate = 9600; // en bits/s

// autres variables
float ecart = 0; // ecart angulaire entre la consigne et l'angle actuel
int commande = 0; // entier entre -255 et +255 représentant la commande à envoyer au moteur

/*
###########################      FIN VARIABLES      ##################################
######################################################################################
######################################################################################
*/
/*
######################################################################################
######################################################################################
##############################      HEADER      ######################################
*/

// remplie correctement le tableau etatMoteur[] avec :
// 1 si m est en train d'etre commandé par boutons, 0 sinon
void setEtatMoteurs();

// renvoie l'écart angulaire entre la consigne et l'angle actuel du moteur m
float getEcart(byte m);

// convertit un écart angulaire en une commande (entier)
int getCommande(float ecart);

// envoie un PWM au moteur m de valeur |commande| et active ou non la pin de sens de m
void commanderMoteur(byte m, int commande);

// renvoie la commande associée aux boutons du moteur m
int getCommandeBouton(byte m);

// convertit la valeur valPota (0..1023) en un angle (-pi..pi)
float potaToAngle(int valPota);
/*
############################      FIN HEADER      ####################################
######################################################################################
######################################################################################
*/
/*
######################################################################################
######################################################################################
##########################      INITIALISATION      ##################################
*/
void setup() {
  
  for (byte m=0; m<5; m++) {
    
    // pin moteurs et sens moteurs en sortie :
    pinMode(pinMoteur[m],OUTPUT);
    pinMode(pinSensMoteur[m],OUTPUT);
    
    // initialisation avec les positions initiales des moteurs
    potaMoteur[m] = analogRead(pinPotaMoteur[m]);
    angleMoteur[m] = potaToAngle(potaMoteur[m]);
    consigneAngleMoteur[m] = angleMoteur[m];
    etatMoteur[m] = 0;
    
  }
  
}
/*
########################      FIN INITIALISATION      ################################
######################################################################################
######################################################################################
*/
/*
######################################################################################
######################################################################################
#############################      PROGRAMME      ####################################
*/
void loop() {
  
  // déterminer l'état de chacun des moteurs (commandé par bouton ou asservi)
  setEtatMoteurs();
  
  // commander chacun des moteurs
  for (byte m=0; m<5; m++) {
    // si le moteur est asservi en angle
    if (etatMoteur[m] == 0) {
      ecart = getEcart(m);
      commande = getCommande(ecart);
      commanderMoteur(m,commande);
    // si le moteur est controllé par bouton
    } else {
      commande = getCommandeBouton(m);
      commanderMoteur(m,commande);
      potaMoteur[m] = analogRead(pinPotaMoteur[m]);
      angleMoteur[m] = potaToAngle(potaMoteur[m]);
      consigneAngleMoteur[m] = angleMoteur[m];
    }
  }
}
/*
###########################      FIN PROGRAMME      ##################################
######################################################################################
######################################################################################
*/

/*
######################################################################################
######################################################################################
#############################      FONCTIONS      ####################################
*/

// remplie correctement le tableau etatMoteur[] avec :
// 1 si m est en train d'etre commandé par boutons, 0 sinon
void setEtatMoteurs(){
  for (byte m=0; m<5; m++) {
    // A FAIRE !!!
    etatMoteur[m] = 0;
  }
}

// renvoie l'écart angulaire entre la consigne et l'angle actuel du moteur m
float getEcart(byte m){
  return consigneAngleMoteur[m] - angleMoteur[m];
}

// convertit un écart angulaire en une commande (entier)
int getCommande(float ecart){
  // A FAIRE !!!
  return 0;
}

// envoie un PWM au moteur m de valeur |commande| et active ou non la pin de sens de m
void commanderMoteur(byte m, int commande){
  if (commande>0) {
    sensMoteur[m] = 0;
  } else {
    sensMoteur[m] = 1;
  }
  digitalWrite(pinSensMoteur[m],sensMoteur[m]);
  analogWrite(pinMoteur[m],abs(commande));
}

// renvoie la commande associée aux boutons du moteur m
int getCommandeBouton(byte m){
  // A FAIRE !!!
  return 0;
}

// convertit la valeur valPota (0..1023) en un angle (-pi..pi)
float potaToAngle(int valPota){
  // A FAIRE !!!
  return 0;
}
/*
###########################      FIN FONCTIONS      ##################################
######################################################################################
######################################################################################
*/
