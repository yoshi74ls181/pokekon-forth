#include <Fat16.h>

#define RTS 2
#define CTS 3

SdCard card;
Fat16 file;

void error()
{
  int i;
  while(1)
  {
    for(i=0;i<500;i++) Serial.write((uint8_t)0x00);
    for(i=0;i<500;i++) Serial.write((uint8_t)0xff);
  }
}

void done()
{
  delay(100);
  while(1){
    Serial.write((uint8_t)0x00);
  }
}

void loop()
{
}

void setup()
{
  int i=0;
  char c,filename[13];

  Serial.begin(9600);

  pinMode(RTS,INPUT);
  pinMode(CTS,OUTPUT);
  digitalWrite(CTS,LOW);

  if(!card.init()||!Fat16::init(&card)) error();

  do
  {
    while(!Serial.available());
    filename[0]=Serial.read();
  }
  while(filename[0]==NULL);

  do
  {
    while(!Serial.available());
    filename[++i]=Serial.read();
  }
  while(filename[i]!='\r'&&i<12);

  filename[i]=NULL;
  
  while(Serial.read()!=0x1a);

  while(digitalRead(RTS)&&!Serial.available());
  
  digitalWrite(CTS,HIGH);

  if(!digitalRead(RTS))
  {  
    if(!file.open(filename,O_READ)) error();

    while ((c=file.read())!=-1)
    {
      Serial.write(c);
      while(digitalRead(RTS));
    }

    Serial.write(0x1a);
  }

  else if(Serial.available())
  {
    if(!file.open(filename, O_CREAT|O_WRITE|O_TRUNC)) error();

    while ((c=Serial.read())!=0x1a)
    {
      file.write(c);
      digitalWrite(CTS,LOW);
      while(!Serial.available());
      digitalWrite(CTS,HIGH);
    }
  }
  
  file.close();
  done();
}

