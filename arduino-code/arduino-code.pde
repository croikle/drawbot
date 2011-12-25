#include "AccelStepper.cpp"
#include <string.h>
#include <stdlib.h>

const int MAX_SPEED = 300;
const int MAX_ACCEL = 1000;
const int LIMIT_A_PIN = 6;
const int LIMIT_B_PIN = 7;
const int ZERO_POS = 1600;
const int WRITE_SPEED = 100;
const int PEN_DELAY_MS = 200;

const int PEN_1 = 12;
const int PEN_2 = 1;
const int PEN_ENABLE = 13;

AccelStepper stepA;
AccelStepper stepB(4, 8,9,10,11);

char buffer[256];
char lastread = '0';
int bufsize = 0;
int comma_index = 0;
int next_a, next_b;
int last_a = 0;
int last_b = 0;
int read_initial_position = 0;
float a_speed;
float b_speed;
bool pen_up;

void matchedMove( int a_pos, int b_pos ){
	int a_steps = a_pos - stepA.currentPosition();
	int b_steps = b_pos - stepB.currentPosition();
	int largest_dimension = abs(a_steps) > abs(b_steps) ? abs(a_steps) : abs(b_steps);
	a_speed = ( (float) a_steps / largest_dimension ) * WRITE_SPEED;
	b_speed = ( (float) b_steps / largest_dimension ) * WRITE_SPEED;

	stepA.move( a_steps );
	stepB.move( b_steps );
	stepA.setSpeed( a_speed );
	stepB.setSpeed( b_speed );
}

/* Preconditions:
 * B is fully extended, and both maximal lengths are greater than the distance
 * between pulleys.
 
 * Protocol:
 * 1. Retracts A until limit switch triggers.
 * 2. Extends A and retracts B until B limit triggers.
 *    Now we know positions, though A line is slack.
 * 3. Run to a good start.
 * 
 */
void calibrate(){
	penUp();
	stepA.setSpeed(-300);
	while( digitalRead(LIMIT_A_PIN) == LOW ) {
		stepA.runSpeed();
		stepB.runSpeed();
	}
	stepA.setCurrentPosition( ZERO_POS );
	stepA.setSpeed(300);
	stepB.setSpeed(-300);
	while( digitalRead(LIMIT_B_PIN) == LOW ) {
		stepA.runSpeed();
		stepB.runSpeed();
	}
	stepB.setCurrentPosition( ZERO_POS );
	matchedMove(3000, 3000);
   while( stepA.distanceToGo() != 0 && stepB.distanceToGo() != 0 ) {
		stepA.runSpeedToPosition();
		stepB.runSpeedToPosition();
   }
}


void setup(void) {
	Serial.begin(9600);
//	Serial.println("Drawbot Serial Interface");
//	Serial.println("input coords as INT,INT<SPACE>");

	pinMode(LIMIT_A_PIN, INPUT);
	pinMode(LIMIT_B_PIN, INPUT);
	pinMode(PEN_1, OUTPUT);
	pinMode(PEN_2, OUTPUT);
	pinMode(PEN_ENABLE, OUTPUT);
	stepA.setMaxSpeed(MAX_SPEED);
	stepA.setAcceleration(MAX_ACCEL);
	stepB.setMaxSpeed(MAX_SPEED);
	stepB.setAcceleration(MAX_ACCEL);
	calibrate();
}
void loop(void) {
	if( digitalRead(LIMIT_A_PIN) == LOW && digitalRead(LIMIT_B_PIN) == LOW ){
		stepA.runSpeed();
		stepB.runSpeed();
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

		/* moving to a new segment */
		/* note: using lastread from the previous cycle */
		if( lastread == '\n' ) {
			penUp();
		}
		/* put the pen down if starting new segment */
		if( (lastread == ' ') && pen_up ) {
			penDown();
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

		matchedMove( next_a, next_b );
		}
}

void penUp() {
	digitalWrite(PEN_1, LOW);
	digitalWrite(PEN_2, HIGH);
	digitalWrite(PEN_ENABLE, HIGH);
	delay(PEN_DELAY_MS);
	digitalWrite(PEN_ENABLE, LOW);

	pen_up = true;
	return 0;
}

void penDown() {
	digitalWrite(PEN_1, HIGH);
	digitalWrite(PEN_2, LOW);
	digitalWrite(PEN_ENABLE, HIGH);
	delay(PEN_DELAY_MS);
	digitalWrite(PEN_ENABLE, LOW);

	pen_up = false;
	return 0;
}
