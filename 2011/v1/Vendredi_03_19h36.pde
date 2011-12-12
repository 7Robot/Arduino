#include <Wire.h>
#include <LiquidCrystal.h>
#include <math.h>

#define Kd 1334.0 // pas par Metres
#define Ka 1156.0 // pas par tour (2Pi)
#define pi 3.14
#define bleu_init 1    // Permet de switcher entre un départ rouge ou bleu. 1 Pour départ bleu
#define xinit 23
#define yinit -31
#define theta_init 0
#define pente_acc 4
#define pente_dec 5
#define vmin 5
#define vmax 15
#define ndecoup 50
#define vitrot 6    // vitesse de rotation avec la fonction "rotation"
#define FERM 200    // temps de fermeture/ouverture pince  ON MET 300 POUR DU 12V
#define eps 0.5     // epsilon pour la fonction 
#define PW 200      // valeur du pwm pour la pince ON MET 235 POUR DU 12V
#define VITCHOPE 7  // vitesse lors d'une chope
#define FIGURE 150  // niveau de détection du sharp pour une figure   *VALEUR INITIALE = 200*
#define OBSTACLE 250// niveau de détection des sharp pour l'obstacle

//////////////////// Position des pions ////////////////////

#define DPION_1 40  // Distance théorique du robot au pion 1 juste avant la fonction chope.
#define DPION_2 40
#define DPION_3 40
#define DPION_4 40

#define PPION_1 30  // Distance théorique du robot au pion sur lequel il va y avoir un empilement.
#define PPION_2 30
#define PPION_3 30
#define PPION_4 30

#define ALPHA 10    // Tolétence lors de la fonction chope avant code erreur.

//////////////////// La connectique ////////////////////

#define pion 9       // entree pour interupteur de pion sur la pince
#define pwm 10       // sortie pour le pwm des moteurs de la pince
#define sens1 11     // sortie n°1 pour le pont H des moteurs de la pince
#define sens2 12     // sortie n°2 pour le pont H des moteurs de la pince
#define sharpD A0    // entree du sharp de DROITE pour détection d'un obstacle
#define sharpG A1    // entree du sharp de GAUCHE pour détection d'un obstacle
#define sharpfig A2  // entree sharp pour détection de figures


//********************  var globales ********************
double x = xinit, y = yinit;
float theta = theta_init ; // pour fct trigo
const int idle = 13;
int i;
char bleu = bleu_init;
int nprofil = 0;
char pions[5] = {0};
char etape = 0;
char actif = 1;   // Permet l'activation ou pas du sharp pour les objets. 1 actif, 0 inactif.


LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

//******************** Setup ********************
void setup()  {
 
   Serial.begin(9600);
   Wire.begin();            // join i2c bus (address optional for master)
   pinMode(idle, INPUT);
   for(i=vmin;i<=vmax;i++)
   {
     nprofil = nprofil + i*(pente_acc+pente_dec);
   }
   lcd.begin(16, 2);
   lcd.clear();
   pinMode (sens1, OUTPUT);
   pinMode (sens2, OUTPUT);
   pinMode(pion, INPUT);
   digitalWrite(pion, HIGH);
   updown('r', 1);
   analogWrite(pwm,PW);
   initPince();    // Ça dure 1,3 secondes
}

/* Programme principal. */
  //En avant = 0
  //Sens horaire = 1
  
  
void loop() {
  
 //////////////////////////////////////////////////////////////////////////////////////////////////////////// ROUGE /////////////////////////////////////////////////////////////////
////////// ROUGE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////// ROUGE /////////////////////////////////////////////////////////////////////////////////////////// ROUGE  ////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////  ROUGE ///////////////////////////////////////////////////////////////////////////////
///////////////////  ROUGE ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// ROUGE  ////////////////////////////////////////////////////
///// ROUGE ////////////////////////////////////////////////////////////////////  ROUGE  ///////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ROUGE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
  if (bleu_init == 0) { 
    
    
  etape = 0;
  avanceR(47,0);
  rotation(90, 1, vitrot); // BLEU : 90 pour la rotation. ROUGE : 89 de rotation.
  avanceR(30, 0);
  rotation(47, 0, vitrot);
  ouverture();
  avanceR(80, 0);
  avanceR(80, 1);
  fermeture();
  rotation(45, 1, vitrot);
  
  avanceR(16,0);
  rotation(90, 1, vitrot); // BLEU : 90 pour la rotation ROUGE : 90 de rotation
  pions[etape] = chope(1, DPION_1);  // Pour le premier coup on ne fait pas d'empilement de toute façon. D'où le 1
  actif = 0;
  
  if(pions[etape] == -1) {
   rotation(90, 0, vitrot);
   avanceR(24, 0);
   rotation(90, 1, vitrot);
  }
  
  else {
  rotation(90,1,vitrot);
  updown('r', 1);
  debloquage();
  avanceR(24, 1);
  fermeture();
  rotation(90, 0, vitrot);
  actif = 1;
  }
 
 
  etape = 1;
  pions[etape] = chope(pions[etape - 1], DPION_2);
  
   if(pions[etape] == -1) {
    rotation(90, 0, vitrot);
    actif = 1;
    }
  
   else if (pions[etape] && pions[etape - 1] == 0) {   // On décide de faire un empilement.
    rotation(90, 1, vitrot);
    pose(PPION_1);
    rotation(180, 0, vitrot);
    updown('r', 1);
    fermeture();
  }
 
   else {                          // On ne fait pas d'empilement.
    rotation(190, 0, vitrot);
    avanceR(18, 0);
    updown('r', 1);
    debloquage();
    avanceR(18, 1);
    fermeture();
    rotation(100, 1, vitrot);
  }
  
 
  etape = 2;
  avanceR(32, 0);
  rotation(90, 1, vitrot);
  pions[etape] = chope(pions[etape - 1], DPION_3);
  
  if (pions[etape] == -1) {
   rotation(90, 0, vitrot);
   actif = 1;
   avanceR(31, 0);
   rotation(90, 1, vitrot); 
  }
  
  else if (pions[etape] && pions[etape - 1] == 0) {      // On empile.
    rotation(90, 1, vitrot);
    avanceR(32, 0);
    rotation(80, 1, vitrot);
    pose(PPION_2);
    actif = 0;
    updown('r', 1);
    fermeture();
    rotation(100, 1, vitrot);
    actif = 1;
    avanceR(63, 0);
    rotation(90, 1, vitrot);
  }
 
  else {                                // On continue normalement.
  rotation(90, 1, vitrot);
  avanceR(10, 1);
  updown('r', 1);
  debloquage();
  avanceR(21, 1);
  fermeture();
  rotation(90, 0, vitrot);
  }
  
 
  etape = 3;
  pions[etape] = chope(pions[etape - 1], DPION_4);
  
  if (pions[etape] == -1) {
   rotation (180, 1, vitrot);
   actif = 1;
   avanceR(105, 0);
   rotation(90, 1, vitrot);
   chope(1, 20);
   avanceR(20, 1);
   ouverture();
  }
  
  else if (pions[etape] && pions [etape - 1] == 0) {      // On empile.
   rotation(90, 1, vitrot);
   pose(PPION_3);
   actif = 0;
   updown('r', 1);
   fermeture();
   debloquage();
   ouverture();
   avanceR(25, 0);
   analogWrite(pwm, 0);
   ordreI2C(1, 1, 1, 1, 0);
   lcd.clear();
   lcd.setCursor(0,0);
   lcd.print("Temps écoulé :");
   lcd.setCursor(0,1);
   lcd.print(millis() / 1000);
   while(1);
   
  /* chope(1, 30);        // Distance à l'empilement que l'on va mettre sur la case bonus.
   updown('r', 1);
   rotation(90, 1, vitrot);
   avanceR(73, 0);
   rotation(90, 1, vitrot);
   avanceR(15, 0);
   debloquage();
   */
  }
  
  else {                         // On continue normalement.
  avanceR(35, 1);
  rotation(178, 1, vitrot);
  avanceR(37, 0);
  rotation(92, 1, vitrot);
  avanceR(25, 0);
  updown('r', 1);
  debloquage();
  }
  
  actif = 1;
  avanceR(30, 1);
  fermeture();
  rotation(90, 0, vitrot);
  avanceR(27, 0);
  rotation(90, 1, vitrot);
  chope(1, 20);            // Distance au pion (ou empilement) adverse que l'on va tirer vers notre case rouge ahahahah (rire maléfique))
  actif = 0;   // superflu mais bon, on ne sait jamais...
  avanceR(20, 0);
  ouverture();
  }
  
//////////////////////////////////////////////////////////////////////////////////////////////////////////// BLEU //////////////////////////////////////////////////////////////////
////////// BLEU ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////// BLEU //////////////////////////////////////////////////////////////////////////////////////////// BLEU ////////////////////
////////////////////////////////////////////////////////////////////////////////////////////// BLEU ////////////////////////////////////////////////////////////////////////////////
/////////////////// BLEU ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// BLEU ////////////////////////////////////////////////////
///// BLEU //////////////////////////////////////////////////////////////////// BLEU ///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// BLEU //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
else {
  
  etape = 0;
  avanceR(49,0);
  rotation(90, 1, vitrot); // BLEU : 90 pour la rotation. ROUGE : 89 de rotation.
  avanceR(30, 0);
  rotation(47, 0, vitrot);
  ouverture();
  avanceR(80, 0);
  avanceR(80, 1);
  fermeture();
  rotation(47, 1, vitrot);
  
  avanceR(16,0);
  rotation(90, 1, vitrot); // BLEU : 90 pour la rotation ROUGE : 90 de rotation
  pions[etape] = chope(1, DPION_1);  // Pour le premier coup on ne fait pas d'empilement de toute façon. D'où le 1
  actif = 0;
  
  if(pions[etape] == -1) {
   rotation(90, 0, vitrot);
   avanceR(24, 0);
   rotation(90, 1, vitrot);
  }
  
  rotation(90,1,vitrot);
  updown('r', 1);
  debloquage();
  avanceR(24, 1);
  fermeture();
  rotation(90, 0, vitrot);
  actif = 1;
 
 
  etape = 1;
  pions[etape] = chope(pions[etape - 1], DPION_2);
  
   if(pions[etape] == -1) {
    rotation(90, 0, vitrot);
    actif = 1;
    }
  
   else if (pions[etape] && pions[etape - 1] == 0) {   // On décide de faire un empilement.
    rotation(90, 1, vitrot);
    pose(PPION_1);
    rotation(180, 0, vitrot);
    updown('r', 1);
    fermeture();
  }
 
   else {                          // On ne fait pas d'empilement.
    rotation(190, 0, vitrot);
    avanceR(18, 0);
    updown('r', 1);
    debloquage();
    avanceR(18, 1);
    fermeture();
    rotation(100, 1, vitrot);
  }
  
 
  etape = 2;
  avanceR(32, 0);
  rotation(90, 1, vitrot);
  pions[etape] = chope(pions[etape - 1], DPION_3);
  
  if (pions[etape] == -1) {
   rotation(90, 0, vitrot);
   actif = 1;
   avanceR(31, 0);
   rotation(90, 1, vitrot);
  }
  
  else if (pions[etape] && pions[etape - 1] == 0) {      // On empile.
    rotation(90, 1, vitrot);
    avanceR(32, 0);
    rotation(80, 1, vitrot);
    pose(PPION_2);
    actif = 0;
    updown('r', 1);
    fermeture();
    rotation(100, 1, vitrot);
    actif = 1;
    avanceR(63, 0);
    rotation(90, 1, vitrot);
  }
 
  else {                                // On continue normalement.
  rotation(90, 1, vitrot);
  avanceR(10, 1);
  updown('r', 1);
  debloquage();
  avanceR(21, 1);
  fermeture();
  rotation(90, 0, vitrot);
  }
  
 
  etape = 3;
  pions[etape] = chope(pions[etape - 1], DPION_4);
  
  if (pions[etape] == -1) {
   rotation (180, 1, vitrot);
   actif = 1;
   avanceR(80, 0);
   rotation(90, 1, vitrot);
   chope(1, 20);
   avanceR(20, 1);
   ouverture();
  }
  
  else if (pions[etape] && pions [etape - 1] == 0) {      // On empile.
   rotation(90, 1, vitrot);
   pose(PPION_3);
   actif = 0;
   updown('r', 1);
   fermeture();
   debloquage;
   ouverture();
   avanceR(25, 0);
   analogWrite(pwm, 0);
   ordreI2C(1, 1, 1, 1, 0);
   lcd.clear();
   lcd.setCursor(0,0);
   lcd.print("Temps écoulé :");
   lcd.setCursor(0,1);
   lcd.print(millis() / 1000);
   while(1);
   /*chope(1, 30);        // Distance à l'empilement que l'on va mettre sur la case bonus.
   updown('r', 1);
   rotation(90, 1, vitrot);
   avanceR(59, 0);
   rotation(90, 1, vitrot);
   avanceR(15, 0);
   debloquage();
   */
  }
  
  else {                         // On continue normalement.
  avanceR(35, 1);
  rotation(185, 1, vitrot);
  avanceR(29, 0);
  rotation(94, 1, vitrot);
  avanceR(40, 0);
  updown('r', 1);
  debloquage();
  }
  
  avanceR(30, 1);
  fermeture();
  rotation(90, 0, vitrot);
  avanceR(27, 0);
  rotation(90, 1, vitrot);
  chope(1, 30);            // Distance au pion (ou empilement) adverse que l'on va tirer vers notre case rouge ahahahah (rire maléfique))
  actif = 0;
  avanceR(15, 0);
  ouverture();
}
  
///////////////////////// ETAPE DE FIN DE PROGRAMME /////////////////////////
  
 analogWrite(pwm, 0);
 ordreI2C(1, 1, 1, 1, 0);
 lcd.clear();
 lcd.setCursor(0,0);
 lcd.print("Temps écoulé :");
 lcd.setCursor(0,1);
 lcd.print(millis() / 1000);

 while(1);
 
}





