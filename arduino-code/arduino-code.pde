#include "AccelStepper.cpp"
#include <string.h>
#include <stdlib.h>

const int MAX_SPEED = 300;
const int MAX_ACCEL = 1000;
const int LIMIT_A_PIN = 6;
const int LIMIT_B_PIN = 7;

AccelStepper stepA;
AccelStepper stepB(4, 8,9,10,11);

char buffer[256];
char lastread;
int bufsize = 0;
int comma_index = 0;
int next_a, next_b;
int a_speed;
int b_speed;
int last_a = 0;
int last_b = 0;
int read_initial_position = 0;

void setup(void) {
	Serial.begin(9600);
//	Serial.println("Drawbot Serial Interface");
//	Serial.println("input coords as INT,INT<SPACE>");

	pinMode(LIMIT_A_PIN, INPUT);
	pinMode(LIMIT_B_PIN, INPUT);
	stepA.setMaxSpeed(MAX_SPEED);
	stepA.setAcceleration(MAX_ACCEL);
	stepB.setMaxSpeed(MAX_SPEED);
	stepB.setAcceleration(MAX_ACCEL);
	calibrate();
}

void calibrate(){
	stepA.setSpeed(-150);
	stepB.setSpeed(300);
	while( digitalRead(LIMIT_A_PIN) == LOW ) {
		stepA.runSpeed();
		stepB.runSpeed();
	}
	stepA.setCurrentPosition( 50 );
	stepA.setSpeed(300);
	stepB.setSpeed(-150);
	while( digitalRead(LIMIT_B_PIN) == LOW ) {
		stepA.runSpeed();
		stepB.runSpeed();
	}
	stepB.setCurrentPosition( 50 );
	stepB.setSpeed(50);
	while(digitalRead(LIMIT_B_PIN) == HIGH ) {
		stepB.runSpeed();
	}
}


void matchedMove( int a_steps, int b_steps ){
	int largest_dimension = abs(a_steps) > abs(b_steps) ? abs(a_steps) : abs(b_steps);
	a_speed = ( float(a_steps) / largest_dimension ) * MAX_SPEED;
	b_speed = ( float(b_steps) / largest_dimension ) * MAX_SPEED;

	stepA.setSpeed( a_speed );
	stepB.setSpeed( b_speed );
	stepA.move( a_steps );
	stepB.move( b_steps );
	stepA.runSpeedToPosition();
	stepB.runSpeedToPosition();
}

void loop(void) {
	if( digitalRead(LIMIT_A_PIN) == LOW && digitalRead(LIMIT_B_PIN) == LOW ){
		stepA.runSpeedToPosition();
		stepB.runSpeedToPosition();
	}
	if( stepA.distanceToGo() == 0 &&
		 stepB.distanceToGo() == 0) {
		Serial.print(".");
		if(!Serial.available()) {
			stepA.disableOutputs();
			stepB.disableOutputs();
			while(!Serial.available()) {}
			/* wait for more data */
			stepA.enableOutputs();
			stepB.enableOutputs();
		}

		bufsize = 0;
		lastread = '0';
		while( lastread!=' ' && lastread!='\n' ) {
			if( Serial.available() ) {
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
			else {
				stepA.disableOutputs();
				stepB.disableOutputs();
				while(!Serial.available()) {}
				/* wait for more data */
			}
		}
		next_a = atoi(buffer); 
		next_b = atoi( buffer+comma_index+1 );

		/* Serial.print("next position:  "); */
		/* Serial.print(next_a); */
		/* Serial.print(", "); */
		/* Serial.println(next_b); */

		//Serial.print(".");
		/* Only printing a single character to acknowledge */

		matchedMove( next_a - stepA.currentPosition(), next_b - stepB.currentPosition() );
		}
}
