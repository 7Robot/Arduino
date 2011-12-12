//*********** lcd*********************
// * LCD RS pin to digital pin 7
// * LCD Enable pin to digital pin 6
// * LCD D4 pin to digital pin 5
// * LCD D5 pin to digital pin 4
// * LCD D6 pin to digital pin 3
// * LCD D7 pin to digital pin 2
// * LCD R/W pin to ground
// * 10K resistor:
// * ends to +5V and ground
// * wiper to LCD VO pin (pin 3)

// un tour : 267 pas 
// diam roue : 6 cm
// 1 m 1334 pas
// 360° 1156 pas


void aff_odo(){

  lcd.setCursor(1,0);
  lcd.print(" x="); 
  lcd.print(x,1); 
  lcd.print(" y=");  
  lcd.print(y,1);
  /*
  lcd.setCursor(0,1);
  lcd.print(180*theta/pi,0);
  lcd.print("deg");*/
}


void aff_couleur()
{
  char xc,yc; // il faut que l'origine soit le centre d'un carreau
 
  xc = floor(x/35.0);
  yc = floor(y/35.0);
 
   if((xc+yc)%2==0) bleu = bleu_init ;
   else bleu = 1^bleu_init;
  
  lcd.setCursor(0,0);
  if(bleu) lcd.print('B');
  else lcd.print('R');
  
}

void aff_dist()
{
 int k=0, gauche=0, droite=0;

  for(k=1;k<=5;k++)
 {
   droite = droite + analogRead(A0);
   delay(1);
   gauche = gauche + analogRead(A1);
   delay(1);
 } 
  /* lcd.setCursor(0,1);
   lcd.print(gauche/5,DEC);
   lcd.print(" ");
   lcd.print(droite/5,DEC);
   
   
  while(gauche/5+droite/5 > 300)
   {
       gauche = 0;
       droite = 0;
       
       for(k=1;k<=5;k++)
       {
         droite = droite + analogRead(A0);
         delay(1);
         gauche = gauche + analogRead(A1);
         delay(1);
       } 
   }
   */
  
   
}

void aff_sharp () {
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("D:");
  lcd.print(analogRead(sharpD));
  lcd.print("   G:");
  lcd.print(analogRead(sharpG));
  lcd.setCursor(0,1);
  lcd.print("Fig:");
  lcd.print(analogRead(sharpfig));
  lcd.print("  ");
  lcd.print(millis()/1000);
  
}
  
  

