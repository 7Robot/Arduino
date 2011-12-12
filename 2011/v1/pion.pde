void updown (char ud, char nbre) {   // u pour monter et d pour descendre
    
  Wire.beginTransmission(65);
  for (int i = 0; i < nbre; i++) 
    Wire.send(byte(ud));
  Wire.endTransmission();
}

void ouverture() {
  digitalWrite(sens2, LOW);
  digitalWrite(sens1, HIGH);
  delay (FERM);
  digitalWrite(sens2, HIGH);
  digitalWrite(sens1, LOW);
  delay(20);
  digitalWrite(sens2, LOW);
}

void fermeture() {
    digitalWrite(sens1, LOW);
    digitalWrite(sens2, HIGH);
    delay (FERM);
    digitalWrite(sens1, HIGH);
    digitalWrite(sens2, LOW);
    delay(20);
    digitalWrite(sens1, LOW);
}

void bloquage () {
  analogWrite (pwm, PW);
  digitalWrite(sens1, LOW);
  digitalWrite(sens2, HIGH);
}

void debloquage () {
  digitalWrite(sens2, LOW);
  analogWrite(pwm, PW);
  digitalWrite(sens2, LOW);
  digitalWrite(sens1, HIGH);
  delay (FERM/1.5);
  digitalWrite(sens2, HIGH);
  digitalWrite(sens1, LOW);
  delay(20);
  digitalWrite(sens2, LOW);
}

/*void chope (char vit) {
  double xavt = x, yavt = y;
  ouverture();
  while (digitalRead(pion)) ordreI2C(1, 10, 0, 1, vit);
  fermeture();
  bloquage();
  updown('u');
  while (abs(x - xavt) > eps || abs(y - yavt) > eps) ordreI2C(1, 10, 1, 1, vit);
}
*/

char chope (char pionAvt, double dth) {   // pionAvt = 1 si c'est une figure, 0 sinon. dmax est la distance théorique au pion objectif au-delà de laquelle le robot c'est raté.
  actif = 0;
  double xavt = x, yavt = y;
  int sf = 1;                  // On met sf à 1 si le pion vers lequel on se dirige le robot est une figure. 0 sinon. -1 si erreur.
  double distance = 0;
  
  ouverture();
  while (digitalRead(pion) && distance < dth + ALPHA) {
    ordreI2C(1, 10, 0, 1, VITCHOPE); 
    distance += 0.74962519;     // On avance de 0.74962519 cm à chaque boucle.
  }
  
  if (distance >= dth + ALPHA ) {
    sf = -1;
    while (abs(x - xavt) > eps || abs(y - yavt) > eps) 
      ordreI2C(1, 10, 1, 1, VITCHOPE);
    fermeture();
    return sf;
  }
    
  fermeture();
  bloquage();
  if (analogRead(sharpfig) > FIGURE) {
     sf = 1;
     lcd.clear();
     lcd.print("FIGURE !!!");
     
      }
  if (sf == 1 && pionAvt == 0){     // Permet de lever la pince à font que lorsqu'on en a vraiment besoin.
     ouverture(); 
     bloquage();
     delay(500);
     updown('u', 15);
     delay (1500);
  }
  
  else {
    updown('u', 1);
    //actif = 1;
  }
  while (abs(x - xavt) > eps || abs(y - yavt) > eps) 
     ordreI2C(1, 10, 1, 1, VITCHOPE);
  return 1; 
}

void initPince () {
  analogWrite(pwm, 70);
  digitalWrite(sens1, LOW);
  digitalWrite(sens2, HIGH);
  delay(1300);
  digitalWrite(sens2, LOW);
  analogWrite(pwm, PW);
}


void pose(double dth) {        // Permet de poser une figure sur un pion pour un empilement.
  double xavt = x, yavt = y;
  double distance = 0;
  
  while(digitalRead(pion) && distance < dth ) {
    ordreI2C(1, 10, 0, 1, VITCHOPE);
    distance += 0.74962519;
  }
  debloquage();
  while (abs(x - xavt) > eps || abs(y - yavt) > eps)
    ordreI2C(1, 10, 1, 1, VITCHOPE);
}
