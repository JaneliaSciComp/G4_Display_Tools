#include <util/twi.h>

#ifdef SERIAL_DEBUG
#include <Streaming.h>
#endif

// Macros
// ----------------------------------------------------------------------------
#define NOP __asm__ __volatile__ ("nop\n\t")

#ifdef SERIAL_DEBUG
#define SET_COL_PINS(value) ({                           \
    PORTD = (PORTD & 0b00000011) + (value & 0b11111100); \
})
#else
#define SET_COL_PINS(value) ((PORTD=value))
#endif

#define SET_ROW_PINS(value) ({                           \
    PORTB = (PORTB & 0b11111100) + (value  >> 6);        \
    PORTC = (PORTC & 0b11000000) + (value & 0b00111111); \
})


// Constants 
// ----------------------------------------------------------------------------
const uint8_t BUF_SIZE = 0xff;
const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint8_t PWM_TYPE_MASK = 0x01;
const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;
const uint8_t PWM_TYPE_2_MSG_SIZE = 9;
const uint8_t PWM_TYPE_16_MSG_SIZE = 33;

// Brightness compensation  - based on number of led on in the given row
// ----------------------------------------------------------------------------
// Adds a stretch factor based on number of leds on. 
//
// BRIGHTNESS_COMP[0] = compensation for 0 leds on (should always be zero)
// BRIGHTNESS_COMP[1] = compensation for 1 led  on
// ...
// BRIGHTNESS_COMP[8] = compensation for 8 leds on
//
// ----------------------------------------------------------------------------
const uint8_t BRIGHTNESS_COMP[9] = {0,0,2,4,6,8,10,12,14};   

// Comensation lookup table
uint8_t compDelayLookupTable[256];

inline uint8_t popCount(uint8_t val)
{
    // Fast count of nonzero bits for uint8_t
    val = val - ((val >> 1) & 0x55);
    val = (val & 0x33) + ((val >> 2) & 0x33);
    return ((val + (val >> 4)) & 0x0F);
}

// Functions
// ----------------------------------------------------------------------------
void setup()
{
    // Setup SPI communications
    pinMode(MISO,OUTPUT);
    pinMode(SS, INPUT);
    SPCR |= _BV(SPE);

    // Set data direction for row pins
    DDRB |= _BV(0) | _BV(1);
    DDRC |= _BV(0) | _BV(1) | _BV(2) | _BV(3)| _BV(4)| _BV(5);

    // Set data direction for col pins
#ifdef SERIAL_DEBUG
    DDRD = 0xfc; 
    Serial.begin(115200);
#else
    DDRD = 0xff; 
#endif

    // Set initial state for column and row pins
    SET_COL_PINS(0x00); 
    SET_ROW_PINS(0xff);

    // Turn off interrupts
    noInterrupts();

    // Create brightness compensation lookup table
    for (int i=0; i<256; i++)
    {
        uint8_t numBitsOn = popCount(uint8_t(i));
        compDelayLookupTable[i] = BRIGHTNESS_COMP[numBitsOn];
    }

}

void loop()
{
    static uint8_t buffer[BUF_SIZE];
    bool dataReady = false;
    uint8_t bufPos = 0;
    uint8_t msgSize;
    uint8_t pwmType;

    // Read incoming spi message
    // ------------------------------------------------------------------------
    while (digitalRead(SS) == 1); // Slow replace with direct port read

    while (!(SPSR & _BV(SPIF)));
    while (true)
    {
        // Read byte from spi data register
        buffer[bufPos] = SPDR;
        bufPos++;
        if (bufPos == 1)
        {
            pwmType = buffer[0] & PWM_TYPE_MASK; 
            if (pwmType == PWM_TYPE_16)
            {
                msgSize = PWM_TYPE_16_MSG_SIZE;
            }
            else
            {
                msgSize = PWM_TYPE_2_MSG_SIZE;
            }
        }
        if (bufPos >= msgSize)
        {
            dataReady = true;
            break;
        }
        while (!(SPSR & _BV(SPIF)));
    }
    while (digitalRead(SS) == 0); // Slow replace with direct port read

    // Read SPSR and SPDR a couple times - to clear out any possible mismatch 
    for (uint8_t i=0; i<5; i++)
    {
        uint8_t dummy0 = SPSR & _BV(SPIF);
        uint8_t dummy1 = SPDR;
    }

    // Update display 
    // ------------------------------------------------------------------------
    if (dataReady)
    {
        uint8_t *bufferPtr = buffer;
        uint8_t row = 0;
        uint8_t pwm = 0;
        uint8_t pwmShift4 = 0;
        uint8_t colValue = 0x00;
        uint8_t dummy = 0;
        uint8_t pwmMaxCount = 0;
        uint8_t delayValue = 0;
        uint8_t delayValueWithComp = 0;

        // Get max count for pwm and delayValue
        if (pwmType == PWM_TYPE_16)
        {
            pwmMaxCount = 16;
        }
        else
        {
            pwmMaxCount = 2;
        }
        delayValue = (*bufferPtr & DELAY_MASK);

        SET_ROW_PINS(~_BV(0));

        while (row < 8)
        {
            // Get column values based on matrix
            colValue = 0x00;
            delayValueWithComp = 0;

            if (pwmMaxCount == 16)
            {
                // 16 -level grayscale (~1.3kHz)
                pwmShift4 = pwm << 4; 

                bufferPtr = buffer + 4*row + 1;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue |= _BV(0); } else { dummy |= _BV(0); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue |= _BV(1); } else { dummy |= _BV(1); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue |= _BV(2); } else { dummy |= _BV(2); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue |= _BV(3); } else { dummy |= _BV(3); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue |= _BV(4); } else { dummy |= _BV(4); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue |= _BV(5); } else { dummy |= _BV(5); }

                bufferPtr++;
                if ((*bufferPtr & 0x0f) > pwm      ) { colValue |= _BV(6); } else { dummy |= _BV(6); }
                if ((*bufferPtr & 0xf0) > pwmShift4) { colValue |= _BV(7); } else { dummy |= _BV(7); }

            }
            else
            {
                // 2-level grayscale (~9.8 kHz)
                bufferPtr = buffer + row + 1;
                if (((*bufferPtr & 0x01) >> 0) > pwm) { colValue |= _BV(0); } else { dummy |= _BV(0); }
                if (((*bufferPtr & 0x02) >> 1) > pwm) { colValue |= _BV(1); } else { dummy |= _BV(1); }
                if (((*bufferPtr & 0x04) >> 2) > pwm) { colValue |= _BV(2); } else { dummy |= _BV(2); }
                if (((*bufferPtr & 0x08) >> 3) > pwm) { colValue |= _BV(3); } else { dummy |= _BV(3); }
                if (((*bufferPtr & 0x10) >> 4) > pwm) { colValue |= _BV(4); } else { dummy |= _BV(4); }
                if (((*bufferPtr & 0x20) >> 5) > pwm) { colValue |= _BV(5); } else { dummy |= _BV(5); }
                if (((*bufferPtr & 0x40) >> 6) > pwm) { colValue |= _BV(6); } else { dummy |= _BV(6); }
                if (((*bufferPtr & 0x80) >> 7) > pwm) { colValue |= _BV(7); } else { dummy |= _BV(7); }
            }
            SET_COL_PINS(colValue);


            // Add brightness compensation to delay value for current row
            delayValueWithComp = delayValue + compDelayLookupTable[colValue]; 
            if (delayValueWithComp > 0)
            {
                for (uint8_t delayCount=0; delayCount < delayValueWithComp; delayCount++)
                {
                    NOP;
                }
            }

            // Update pwm count and row count
            pwm++;
            if (pwm >= pwmMaxCount)
            {
                pwm = 0;
                row++;
                SET_COL_PINS(0x00);
                if (row < 8)
                {
                    SET_ROW_PINS(~_BV(row%8));
                }
                else
                {
                    SET_ROW_PINS(0xff);
                }
            }

        } // while (row<8)
    }
}


