#include "AccelStepper.cpp"
#include <string.h>
#include <stdlib.h>

AccelStepper stepA;
AccelStepper stepB(4, 8,9,10,11);

const int MAX_SPEED = 300;
const int MAX_ACCEL = 1000;

char buffer[256];
char lastread;
int bufsize = 0;
int comma_index = 0;
int next_a, next_b;
int a_speed;
int b_speed;

void setup(void) {
	Serial.begin(9600);
	Serial.println(" library test");

	stepA.setMaxSpeed(MAX_SPEED);
	stepA.setAcceleration(MAX_ACCEL);
	stepB.setMaxSpeed(MAX_SPEED);
	stepB.setAcceleration(MAX_ACCEL);
	stepA.move(0);
	stepB.move(0);
}

void matchedMove( int a_steps, int b_steps ){
	if( abs(a_steps) >= abs(b_steps) ) {
		b_speed = ( float(b_steps) / abs(a_steps) ) * MAX_SPEED ;
		a_speed = MAX_SPEED;
	} else {
		a_speed = ( float(a_steps) / abs(b_steps) ) * MAX_SPEED ;
		b_speed = MAX_SPEED ;
	}

	stepA.setSpeed( a_speed );
	stepB.setSpeed( b_speed );
	stepA.move( a_steps );
	stepB.move( b_steps );
	stepA.runSpeedToPosition();
	stepB.runSpeedToPosition();
}

void speedTest(){
	stepA.setSpeed(MAX_SPEED);
	stepB.setSpeed(MAX_SPEED);
	stepA.move( -300 );
	stepB.move( -500 );
}

void loop(void) {
	stepA.runSpeedToPosition();
	stepB.runSpeedToPosition();
	if( stepA.distanceToGo() == 0 &&
		 stepB.distanceToGo() == 0 &&
		 Serial.available() > 0){
		bufsize = 0;
		lastread = '0';
		while( Serial.available() && lastread!=' ' && lastread!='\n' ) {
			lastread = Serial.read();
			if( lastread == ',' ) {
				comma_index = bufsize;
				buffer[bufsize] = '\0';
			} else if( lastread == ' ' ) {
				buffer[bufsize] = '\0';
			} else if( lastread == '\n' ) {
				buffer[bufsize] = '\0';
			} else {
				buffer[bufsize] = lastread;
			}
			bufsize++; 
		}
		next_a = atoi(buffer); 
		next_b = atoi( buffer+comma_index+1 );

		Serial.print("next_a: ");
		Serial.println(next_a);
		Serial.print("next_b: ");
		Serial.println(next_b);
		matchedMove( next_a, next_b );
		}
	//if(stepA.distanceToGo() == 0) speedTest();
}
