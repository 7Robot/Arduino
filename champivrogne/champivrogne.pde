/*

Code refait par Christophe et Ludovic pour le Champivrogne.
Récupéré par Martin 2011-12-15

Branchement ?

*/


#include <Servo.h>
#include <avr/sleep.h>

Servo myservo;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created
int bouton1 = 0; //Interruption 0 (pin 2)
int bouton2 = 1; //Interruption 1 (pin 3)

int bounce_bt1;
int bounce_bt2;
int last_interrupt1;
int last_interrupt2;

volatile int angleServo = 90; //Définition de la variable en volatile pour pouvoir la modifier dans les interruptions
//Variable pour la Machine à états :
//0 => initialisation
#define INIT 0
//1 => partie en cours
#define JEU 1
//2 => victoire
#define VICTOIRE 2
#define PAUSE 3
#define DECOMPTE 4
volatile unsigned int etat = 0;

int LedMasse = 8;
int Led0 = 12; //LED la plus à gauche
int Led1 = 13;
int Led2 = 11; //LED centrale
int Led3 = 9;
int Led4 = 10; //LED la plus à droite
int tableauLeds[5]={Led0, Led1, Led2, Led3, Led4};
int indice=0;

unsigned long debutJeu=0;

void setup() {
  myservo.attach(6);  // attaches the servo on pin 9 to the servo object
  digitalWrite(2, HIGH); //Supprime l'état de haute impédance lorsque l'interrupteur est ouvert
  digitalWrite(3, HIGH); //Supprime l'état de haute impédance lorsque l'interrupteur est ouvert
  attachInterrupt(bouton1, bouton1_int, FALLING);
  attachInterrupt(bouton2, bouton2_int, FALLING);
  
  pinMode(LedMasse, OUTPUT);
  pinMode(Led0, OUTPUT);
  pinMode(Led1, OUTPUT);
  pinMode(Led2, OUTPUT);
  pinMode(Led3, OUTPUT);
  pinMode(Led4, OUTPUT);
  digitalWrite(LedMasse, LOW);
  digitalWrite(5,LOW);
  
  pinMode(5, OUTPUT);
  last_interrupt1=0;
  last_interrupt2=0;
  bounce_bt1=0;
  bounce_bt2=0;
  
  angleServo = 90;
  myservo.write(angleServo);
  delay(1000);
  etat=DECOMPTE;
}

void loop() {
  switch (etat)// Machine à états
  {
    case INIT ://Initialisation
      setup();
      break;
      
    case JEU ://Jeux en cours
      myservo.write(angleServo);
      progression(); //Gère l'allumage des Leds pendant la progression du jeu
      if (millis()-debutJeu > 10000)
      {
        etat=VICTOIRE;
      }
      break;
      
    case VICTOIRE ://Victoire
      detachInterrupt(bouton1);
      detachInterrupt(bouton2);
      analogWrite(5,125);
      clignoter(1, 500);
      digitalWrite(5,LOW);
      clignoter(5, 500);
      etat=PAUSE;
      break;
      
    case PAUSE ://Pause
      sleep();
      //etat = DECOMPTE;
      break;
      
    case DECOMPTE ://Decompte
      analogWrite(5,125);
      clignoter(1, 250);
      digitalWrite(5,LOW);
      clignoter(1, 250);
      analogWrite(5,125);
      clignoter(1, 250);
      digitalWrite(5,LOW);
      clignoter(1, 250);
      analogWrite(5,125);
      clignoter(1, 250);
      digitalWrite(5,LOW);
      debutJeu=millis();
      etat=JEU;
      break;
      
    default :
      etat=INIT;
      break;
  }
  
  
}

void bouton1_int() {
  if (etat == JEU)
  {
    bounce_bt1=millis();
    if((bounce_bt1 - last_interrupt1 )> 100)
    {
	angleServo=angleServo+5;
	last_interrupt1 = bounce_bt1;
    }
    if (angleServo >= 179)
    {
      angleServo=179;
      etat = VICTOIRE;
    }
  }
}

void bouton2_int() {
  if (etat == JEU)
  {
    bounce_bt2=millis();
    if ((bounce_bt2 - last_interrupt2) > 100)
    {
        angleServo=angleServo-5;
	last_interrupt2 = bounce_bt2;
    }
    if (angleServo <= 0)
    { 
      angleServo=0;
      etat = VICTOIRE;
    }
  }
}

void progression()
{
  if (angleServo <= 22)
  {
    digitalWrite(Led0, HIGH);
    digitalWrite(Led1, HIGH);
    digitalWrite(Led2, HIGH);
    
    digitalWrite(Led3, LOW);
    digitalWrite(Led4, LOW);
  }
  else if (angleServo > 22 && angleServo <= 67)
  {
    digitalWrite(Led1, HIGH);
    digitalWrite(Led2, HIGH);
    
    digitalWrite(Led0, LOW);
    digitalWrite(Led3, LOW);
    digitalWrite(Led4, LOW);
  }
  else if (angleServo > 67 && angleServo <=  112)
  {
    digitalWrite(Led2, HIGH);
    
    digitalWrite(Led0, LOW);
    digitalWrite(Led1, LOW);
    digitalWrite(Led3, LOW);
    digitalWrite(Led4, LOW);
  }
  else if (angleServo >112 && angleServo <= 157)
  {
    digitalWrite(Led2, HIGH);
    digitalWrite(Led3, HIGH);
    
    digitalWrite(Led0, LOW);
    digitalWrite(Led1, LOW);
    digitalWrite(Led4, LOW);
  }
  else
  {
    digitalWrite(Led3, HIGH);
    digitalWrite(Led4, HIGH);
    digitalWrite(Led2, HIGH);
    
    digitalWrite(Led0, LOW);
    digitalWrite(Led1, LOW);
  }
}

void clignoter(int NbreFois, int tempsMs){
  boolean clign=true;
  
  for (int i=0; i<2*NbreFois ; i++)
  {
    if (clign)
    {
      digitalWrite(Led0, HIGH);
      digitalWrite(Led1, HIGH);
      digitalWrite(Led2, HIGH);
      digitalWrite(Led3, HIGH);
      digitalWrite(Led4, HIGH);
    }
    else
    {
      digitalWrite(Led0, LOW);
      digitalWrite(Led1, LOW);
      digitalWrite(Led2, LOW);
      digitalWrite(Led3, LOW);
      digitalWrite(Led4, LOW);
    }
    delay(tempsMs);
    clign=!clign;
  }
}

void sleep()
{
  delay(100);
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);   // sleep mode is set here
  sleep_enable();
  
  attachInterrupt(bouton1, wakeUp, LOW);
  attachInterrupt(bouton2, wakeUp, LOW);
  
  sleep_mode();//On rentre dans le mode sleep, jusqu'à une interruption
  sleep_disable();
  
  attachInterrupt(bouton1, bouton1_int, FALLING);
  attachInterrupt(bouton2, bouton2_int, FALLING);
  
}

void wakeUp()
{
  if (etat == PAUSE)
  {
    etat = INIT;
  }
}
