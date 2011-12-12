void ordreI2C(char masterA, char npas, char inv, char ratio, char vit)
{
  char b1, b2, sgn ;
  double d;
  int time;

  if(npas != 0 && npas < 128)
    {
    b1 = masterA << 7;
    b1 = b1 + npas ;
    
    b2 = inv << 3;
    b2 = b2 + ratio;
    b2 = b2 << 4;
    b2 = b2 + vit ;
    
    
    Wire.beginTransmission(64); 
    Wire.send(byte(b1));        
    Wire.send(byte(b2));               
    Wire.endTransmission();
    
  
    // Calculs odometire
    if(ratio!=0) // translation rectiligne
    {
      sgn = 1-2*inv ; // CHAR ?
      
      
      d = sgn*100*npas/Kd;
      x = x + d*sin(theta);
      y = y + d*cos(theta);
      

    }
    else //rotation
    {
      sgn = (1-2*inv)*(1-2*masterA) ; // au signe pres
    
      theta=theta + 2*sgn*npas*pi/Ka;
    }
    
    if((analogRead(sharpD) > OBSTACLE || analogRead(sharpG) > OBSTACLE) && actif)
    {
      Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b10010100));       
       Wire.endTransmission();
       
      Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b10010100));       
       Wire.endTransmission();
       
      Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b10010100));       
       Wire.endTransmission();
       
       while(!digitalRead(idle));
       delay(1000);
       
       Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b00010100));       
       Wire.endTransmission();
       
       Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b00010100));       
       Wire.endTransmission();
       
       Wire.beginTransmission(64); 
       Wire.send(byte(0b11111111));        
       Wire.send(byte(0b00010100));       
       Wire.endTransmission();
    }

   
    aff_odo();
    //aff_couleur();
    //aff_dist();
    //aff_sharp();
    
    time = millis()/1000;
    if(time > 87)
    {
       Wire.beginTransmission(64); 
       Wire.send(byte(0b10000000));        
       Wire.send(byte(0b10000000));               
       Wire.endTransmission();
       analogWrite(pwm, 0);
       
       lcd.clear();
       lcd.setCursor(0,0);
       lcd.print("FINI");
       
       while(1);
    }
    
    while(!digitalRead(idle));
  }
}



void ordreI2CInt(char masterA, int npas, char inv, char ratio, char vit)               //pour nbpas>127 !!!!!!!!!!
{
   do {
      if(npas > ndecoup) {
         ordreI2C(masterA,ndecoup,inv,ratio,vit);
         npas = npas - ndecoup ;
      }
      else if (npas <= ndecoup) {
         ordreI2C(masterA,npas,inv,ratio,vit);
         npas = 0 ;  
      } 
   } while(npas != 0);
}

