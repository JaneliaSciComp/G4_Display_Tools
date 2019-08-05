#include <util/atomic.h>
#include <SPI.h>
#include "i2cmaster.h"

// Macros
// ----------------------------------------------------------------------------
#define NOP __asm__ __volatile__ ("nop\n\t")

#define RESET_ALL_SLAVES ({                         \
    PORTD &= ~(_BV(4) | _BV(5) | _BV(6) | _BV(7));  \
    NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP; NOP;NOP; NOP;  \
    PORTD |= _BV(4) | _BV(5) | _BV(6) | _BV(7);     \
})

#define RESET_SLAVE(num) ({                         \
    PORTD &= ~_BV(num);                             \
    NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP; NOP;NOP; NOP;  \
    PORTD |= _BV(num);                              \
})


// Global Constants
// ----------------------------------------------------------------------------
enum {BUFFER_SIZE=255};
enum {I2C_NUM_SLAVES=4};
const uint8_t I2C_SLAVE_ADDRESS[I2C_NUM_SLAVES] = {1,2,3,4};
const uint8_t I2C_TYPE_2_MSG_SIZE = 9;
const uint8_t I2C_TYPE_16_MSG_SIZE = 33;
const uint8_t PWM_TYPE_MASK = 0x01;
const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;


class SpiBuffer
{
    public:

        SpiBuffer()
        {
            for (uint8_t i=0; i<BUFFER_SIZE; i++)
            {
                data[i] = 0;
            }
            clear();
        }

        inline void clear()
        {
            dataLen = 0;
            dataReady = false;
            errorFlag = false;
        };

        uint8_t data[BUFFER_SIZE];
        uint8_t dataLen;
        bool dataReady;
        bool errorFlag;
};

// ----------------------------------------------------------------------------

void setup()
{
    // Setup slave reset lines
    DDRD |= _BV(4) | _BV(5) | _BV(6) | _BV(7);
    RESET_ALL_SLAVES;

    // Setup SPI communications
    pinMode(MISO,OUTPUT);
    pinMode(SS, INPUT);
    SPCR |= _BV(SPE);

    // Setup I2C communications
    pinMode(A4,INPUT_PULLUP);
    pinMode(A5,INPUT_PULLUP);
    i2c_init();   

    // Turn off interrupts
    noInterrupts(); 
}

// ----------------------------------------------------------------------------

void loop()
{
    static SpiBuffer buffer = SpiBuffer();
    uint8_t spiMsgSize;
    uint8_t i2cMsgSize;
    uint8_t pwmType;
    uint8_t delayValue;

    // Spin loop for receiving SPI messages
    // ------------------------------------------------------------------------
    while (!(SPSR & _BV(SPIF)));
    while (true)
    {
        // Read byte from spi data register
        buffer.data[buffer.dataLen] = SPDR;
        buffer.dataLen++;

        if (buffer.dataLen == 1)
        {
            pwmType = buffer.data[0] & PWM_TYPE_MASK; 
            if (pwmType == PWM_TYPE_16)
            {
                i2cMsgSize = I2C_TYPE_16_MSG_SIZE;
                spiMsgSize = 4*I2C_TYPE_16_MSG_SIZE;
            }
            else
            {
                i2cMsgSize = I2C_TYPE_2_MSG_SIZE;
                spiMsgSize = 4*I2C_TYPE_2_MSG_SIZE;
            }

        }

        if (buffer.dataLen == spiMsgSize)
        {
            buffer.dataReady = true;
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

    // Send i2c messages to panels
    // ------------------------------------------------------------------------
    if (buffer.dataReady)
    {
        bool rtnFlag;
        bool errFlag = false;

        for (uint8_t slaveInd=0; slaveInd < I2C_NUM_SLAVES; slaveInd++)
        {
            rtnFlag = i2c_start((I2C_SLAVE_ADDRESS[slaveInd] << 1) + I2C_WRITE);     
            if (!rtnFlag)
            {
                uint8_t index0 = i2cMsgSize*slaveInd;
                uint8_t index1 = i2cMsgSize*(slaveInd+1);
                for (uint8_t i=index0; i<index1; i++) 
                {
                    rtnFlag = i2c_write(buffer.data[i]);
                    if (rtnFlag)
                    {
                        errFlag = true;
                        break;
                    }
                }
                i2c_stop();                                   
            }
            else
            {
                errFlag = true;
            }

            if (errFlag)
            { 
                // Reset i2c communications
                TWCR = 0;         
                i2c_init();
                errFlag = false;
                break;
            }
        }
    }

    // Reset SPI buffer for next message
    // ------------------------------------------------------------------------
    buffer.clear();
}

