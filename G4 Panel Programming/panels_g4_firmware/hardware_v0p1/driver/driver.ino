#include <util/twi.h>

// Macros
// ----------------------------------------------------------------------------
#define NOP __asm__ __volatile__ ("nop\n\t")

#define SET_COL_PINS(value) ({                           \
    PORTB = (PORTB & 0b11000000) + (value & 0b00111111); \
    PORTC = (PORTC & 0b11111100) + (value  >> 6);        \
})

#define SET_ROW_PINS(value) ((PORTD=value))

// Constants 
// ----------------------------------------------------------------------------
const uint8_t ADDRESS = 4;
const uint8_t BUF_SIZE = 0xff;
const uint16_t TWI_MAX_COUNT = 0xffff;
const uint8_t PWM_TYPE_MASK = 0x01;
const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint8_t I2C_TYPE_2_MSG_SIZE = 9;
const uint8_t I2C_TYPE_16_MSG_SIZE = 33;
const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;


// Functions
// ----------------------------------------------------------------------------
void setup()
{
    // Setup I2C communications
    TWAR = ADDRESS << 1;
    TWCR =  (1<<TWEA) | (1<<TWINT) | (1<<TWEN);

    // Set data direction for column pins
    DDRB |= _BV(0) | _BV(1) | _BV(2) | _BV(3)| _BV(4)| _BV(5);
    DDRC |= _BV(0) | _BV(1);

    // Set data direction for row pins
    DDRD = 0xff;

    // Set initial state for column and row pins
    SET_COL_PINS(0xff); 
    SET_ROW_PINS(0x00);

    // Turn off interrupts
    noInterrupts();
}

void loop()
{
    static uint8_t buffer[BUF_SIZE];
    static uint8_t bufPos = 0;
    uint8_t twiCount = 0;
    uint8_t twiError = false;

    // Reading incoming i2c messages 
    // ------------------------------------------------------------------------
    while (true)
    {
        // Spin-loop - wait for incoming bytes w/ timeout count
        twiCount = 0;
        twiError = false;
        while (!(TWCR & _BV(TWINT)))
        {
            twiCount++;
            if (twiCount >= TWI_MAX_COUNT)
            {
                bufPos = 0;
                TWCR &= ~((1<<TWEA) | (1<<TWEN));
                twiError = true;
                break;
            }
        }
        if (twiError)
        {
            TWCR =  (1<<TWEA) | (1<<TWINT) | (1<<TWEN);
        }
        else
        {
            if( (TWSR & 0xF8) == TW_SR_SLA_ACK )
            {
                // Address acknowledge - start of message
                bufPos = 0;
                TWCR |=   (1<<TWINT) | ((0<<TWEA) | 1<<TWEN);
            }
            else if((TWSR & 0xF8) == TW_SR_DATA_ACK)
            {
                // Received data byte
                if (bufPos < BUF_SIZE)
                { 
                    buffer[bufPos] = TWDR;
                    bufPos++;
                    TWCR |= (1<<TWINT) | (1<<TWEA) | (1<<TWEN); 
                }
                else
                {
                    TWCR |=  (1<<TWINT) | (0<<TWEA) | (1<<TWEN); 
                }
            }
            else
            {
                // None of the above prepare TWI to be addressed again
                TWCR |=  (1<<TWINT) | (1<<TWEA) | (1<<TWEN);
                break;
            }
        }
    }

    // Update display 
    // ------------------------------------------------------------------------
    if (bufPos > 0)
    {
        uint8_t *bufferPtr = buffer;
        uint8_t row = 0;
        uint8_t pwm = 0;
        uint8_t pwmShift4 = 0;
        uint8_t colValue = 0xff;
        uint8_t dummy = 0;
        uint8_t pwmMaxCount;
        uint8_t delayValue;

        // Get pwm type - reject if message size is incorrect
        if ((*buffer & PWM_TYPE_MASK) == PWM_TYPE_16)
        {
            pwmMaxCount = 16;
            if (bufPos != I2C_TYPE_16_MSG_SIZE)
            {
                bufPos = 0;
                return;
            }
        }
        else
        {
            pwmMaxCount = 2;
            if (bufPos != I2C_TYPE_2_MSG_SIZE)
            {
                bufPos = 0;
                return;
            }
        }
        delayValue = (*buffer & DELAY_MASK);

        row = 0;
        while (row < 8)
        {
            // Get column values based on matrix
            colValue = 0xff;
            if (pwmMaxCount == 16)
            {
                // 16 -level grayscale (~1.3kHz)
                pwmShift4 = pwm << 4; 

                bufferPtr = buffer + 4*row + 1;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue &= ~_BV(0); } else { dummy &= ~_BV(0); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue &= ~_BV(1); } else { dummy &= ~_BV(1); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue &= ~_BV(2); } else { dummy &= ~_BV(2); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue &= ~_BV(3); } else { dummy &= ~_BV(3); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue &= ~_BV(4); } else { dummy &= ~_BV(4); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue &= ~_BV(5); } else { dummy &= ~_BV(5); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue &= ~_BV(6); } else { dummy &= ~_BV(6); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue &= ~_BV(7); } else { dummy &= ~_BV(7); }
            }
            else
            {
                // 2-level grayscale (~9.8 kHz)
                bufferPtr = buffer + row + 1;
                if (((*bufferPtr & 0x01) >> 0) > pwm) { colValue &= ~_BV(0); } else { dummy &= ~_BV(0); }
                if (((*bufferPtr & 0x02) >> 1) > pwm) { colValue &= ~_BV(1); } else { dummy &= ~_BV(1); }
                if (((*bufferPtr & 0x04) >> 2) > pwm) { colValue &= ~_BV(2); } else { dummy &= ~_BV(2); }
                if (((*bufferPtr & 0x08) >> 3) > pwm) { colValue &= ~_BV(3); } else { dummy &= ~_BV(3); }
                if (((*bufferPtr & 0x10) >> 4) > pwm) { colValue &= ~_BV(4); } else { dummy &= ~_BV(4); }
                if (((*bufferPtr & 0x20) >> 5) > pwm) { colValue &= ~_BV(5); } else { dummy &= ~_BV(5); }
                if (((*bufferPtr & 0x40) >> 6) > pwm) { colValue &= ~_BV(6); } else { dummy &= ~_BV(6); }
                if (((*bufferPtr & 0x80) >> 7) > pwm) { colValue &= ~_BV(7); } else { dummy &= ~_BV(7); }
            }
            SET_COL_PINS(colValue);

            // Update pwm count and row count
            pwm++;
            if (pwm >= pwmMaxCount)
            {
                pwm = 0;
                row++;
                SET_COL_PINS(0xff);
                SET_ROW_PINS(_BV(row%8));
            }
            if (delayValue > 0)
            {
                for (uint8_t delayCount=0; delayCount < delayValue; delayCount++)
                {
                    NOP;
                }
            }
        }

        // Reset buffer position
        bufPos = 0;
    }
}
