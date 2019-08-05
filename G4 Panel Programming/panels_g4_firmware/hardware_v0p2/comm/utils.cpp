#include "utils.h"
#include <Arduino.h>
#include "constants.h"

Buffer::Buffer()
{
    for (uint8_t i=0; i<BUFFER_SIZE; i++)
    {
        data[i] = 0;
    }
    clear();
}


void Buffer::clear()
{ 
    dataLen = 0;
    dataReady = false;
    errorFlag = false;
}


void resetAllSlaves()
{
    *SLAVE_RESET_OUT_REG &= ~SLAVE_RESET_PIN_MASK;
    NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;  
    *SLAVE_RESET_OUT_REG |=  SLAVE_RESET_PIN_MASK;
}


void initSlaveResetPins()
{
    *SLAVE_RESET_DDR_REG |= SLAVE_RESET_PIN_MASK;
}
