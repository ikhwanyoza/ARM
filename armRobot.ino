#include <Servo.h>  

char buffer[10];  
Servo s1;    
Servo s2;    
Servo s3;
Servo s4;

void setup()  
{  
        s1.attach(9);   
        s2.attach(10);    
        s3.attach(11);
        s4.attach(12);
        Serial.begin(9600); 
        Serial.flush();
        Serial.println("STARTING..."); 
        awal();
}  
void loop()  
{  
        if (Serial.available() > 0) {  
                int index=0; 
                delay(100);  
                int numChar = Serial.available();  
                if (numChar>10) { 
                numChar=10; 
                } 
                while (numChar--) { 
                        buffer[index++] = Serial.read(); 
                }
                splitString(buffer);  
        } 
}

void splitString(char* data) { 
        Serial.print("Data entered: "); 
        Serial.println(data); 
        char* parameter; 
        parameter = strtok (data, " ,");  
        while (parameter != NULL) {  
                setServo(parameter);  
                parameter = strtok (NULL, " ,");  
        } 
                
        for (int x=0; x<9; x++) { 
                buffer[x]='\0'; 
        } 
        Serial.flush(); 
}

void awal(){
  s1.write(90);
  s2.write(90);
  s3.write(90);
  s4.write(90);
  delay(100);
}

void setServo(char* data) {
        if ((data[0] == 'A') || (data[0] == 'a')) { 
                int firstVal = strtol(data+1, NULL, 10); // String to long integer 
                firstVal = constrain(firstVal,0,180); // Constrain values 
                s1.write(firstVal);
                delay(100); 
                Serial.print("Servo1 is set to: "); 
                Serial.println(firstVal); 
        } 
        if ((data[0] == 'B') || (data[0] == 'b')) { 
                int secondVal = strtol(data+1, NULL, 10); // String to long integer 
                secondVal = constrain(secondVal,0,180); // Constrain the values 
                s2.write(secondVal); 
                delay(100);
                Serial.print("Servo2 is set to: "); 
                Serial.println(secondVal); 
        }
        if ((data[0] == 'C') || (data[0] == 'c')) { 
                int thirdVal = strtol(data+1, NULL, 10); // String to long integer 
                thirdVal = constrain(thirdVal,0,180); // Constrain the values 
                s3.write(thirdVal); 
                delay(100);
                Serial.print("Servo3 is set to: "); 
                Serial.println(thirdVal); 
        }
        if ((data[0] == 'D') || (data[0] == 'd')) { 
                int fourthVal = strtol(data+1, NULL, 10); // String to long integer 
                fourthVal = constrain(fourthVal,0,180); // Constrain the values 
                s4.write(fourthVal); 
                delay(100);
                Serial.print("Servo4 is set to: "); 
                Serial.println(fourthVal); 
        }
} 

