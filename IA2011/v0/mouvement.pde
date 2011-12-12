void rampe(char vi, char vf)
{
  char vit = 0 ;
  vit = vi;
   
  if(vi < vf) // on accelere
  {
    for(vit=vi;vit<vf;vit++)
    {
      ordreI2CInt(1,pente_acc*vit,0,1,vit);
    }
  }
  else if(vi > vf) // on deccelere
  {
    for(vit=vi;vit>vf;vit--)
    {
      ordreI2CInt(1,pente_dec*vit,0,1,vit);
    }
  }
}

void rotation(int angle, char sens ,char vit)  //sens horaire= 1
{
  int nbpas_rot;
  
	if(bleu_init == 1) // On inverse le sens de toutes les rotations si on joue Bleu.
        {
          sens = 1 - sens;
        }
        
        if(sens) nbpas_rot=map(angle,0,360,0,Ka-2); 
        else nbpas_rot=map(angle,0,360,0,Ka+10);
        
         	
	ordreI2CInt(1,nbpas_rot,sens,0,vit);
}

void avance(int d , char sens , int vit)  // tout droit = 0
{
  int npas;

  npas=floor(0.5+(Kd*d)/100.0);
  ordreI2CInt(1,npas,sens,1,vit); 
}

void avanceR(int d,char sens)
{
  int npas = floor(0.5+(d*Kd)/100.0);
  char vit = vmin;
  int nmilieu = floor(npas/2); // pas exact
  int ninit = npas;
  int ndec = 0 ;

  if(npas < 2*(pente_acc+pente_dec)*10)
  {
    ordreI2CInt(1,npas,sens,1,vit);
  }
  else if(npas >= 2*(pente_acc+pente_dec)*10 && npas <= nprofil)
  {
    do{
      ordreI2CInt(1,vit*pente_acc,sens,1,vit);
      npas = npas - vit*pente_acc;
      if(vit < vmax) vit++;
    } while(npas > (nmilieu + 2*vit*pente_dec));
    do{
      ordreI2CInt(1,vit*pente_dec,sens,1,vit);
      npas = npas - vit*pente_dec;
      if(vit > vmin) vit--;
    } while(npas > 0 );
  }
  else
  {
    do{
      ordreI2CInt(1,vit*pente_acc,sens,1,vit);
      npas = npas - vit*pente_acc;
      vit++;
    }while(vit<vmax);

    for(i=vmin;i<=vmax;i++)
    {
      ndec = ndec + i*pente_dec ;
    }

    do
    {
      ordreI2CInt(1,vit*pente_dec,sens,1,vit);
      npas = npas - vit*pente_dec;
    } while(npas > ndec + vit*pente_dec);

    do {
      ordreI2CInt(1,vit*pente_dec,sens,1,vit);
      npas = npas - vit*pente_dec;
      if(vit > vmin) vit--;

    } while(npas > 0 );
  }
}



