#include "mspim_spi.h"
#include <Arduino.h>


void MSPIM_SendDataToSlaves(Buffer &buffer)
{
    if (buffer.dataReady)
    {
        uint8_t msgSize = getBufferMsgSize(buffer);
        for (uint8_t i=0; i<NUM_SLAVE; i++)
        { 
            uint8_t ind0 = msgSize*i; 
            uint8_t ind1 = msgSize*(i+1);
            MSPIM_WriteBuffer(SLAVE_MSPIM_SS_PIN_MASK[i],buffer,ind0,ind1); 
        }
    }
}


void MSPIM_WriteBuffer(uint8_t ssPinMask, Buffer &buffer, uint8_t ind0, uint8_t ind1)
{
    if ((ind0 >= BUFFER_SIZE) || (ind1 >= BUFFER_SIZE))
    {
        return;
    }
    // Enable slave select
    *SLAVE_MSPIM_OUT_REG &= ~ssPinMask;
    for (uint8_t i=ind0; i<ind1; i++)
    {
        MSPIM_TransferByte(buffer.data[i]);
    }
    // Wait for all transmissions to finish
    while ((UCSR0A & _BV(TXC0)) == 0)
    {}
    // Disable slave select
    *SLAVE_MSPIM_OUT_REG |= ssPinMask;
}


void MSPIM_WriteBuffer(uint8_t ssPinMask, Buffer &buffer,uint8_t numBytes=BUFFER_SIZE)
{
    if (numBytes >= BUFFER_SIZE)
    {
        return;
    }
    // Enable slave select
    *SLAVE_MSPIM_OUT_REG &= ~ssPinMask;
    // Transfer buffer
    for (uint8_t i=0; i<numBytes; i++)
    {
        MSPIM_TransferByte(buffer.data[i]);
    }
    // Wait for all transmissions to finish
    while ((UCSR0A & _BV(TXC0)) == 0)
    {}
    // Disable slave select
    *SLAVE_MSPIM_OUT_REG |= ssPinMask;
}


void MSPIM_Initialize()
{
    // Set Chip select lines to outputs
    uint8_t ssPinMask = 0;
    for (uint8_t i=0; i<NUM_SLAVE; i++)
    {
        ssPinMask |= SLAVE_MSPIM_SS_PIN_MASK[i];
    }
    *SLAVE_MSPIM_DDR_REG |= ssPinMask;

    UBRR0 = 0;                               // Must be zero before enabling the transmitter
    UCSR0A = _BV (TXC0);                     // any old transmit now complete 
    UCSR0C = _BV(UMSEL00) | _BV(UMSEL01);    // Master SPI mode
    UCSR0B = _BV(TXEN0)   | _BV(RXEN0);      // transmit enable and receive enable
    //UBRR0 = 3;                               // Must be done last, see page 206 (3 => 2 Mhz clock rate)
    UBRR0 = 1;                               // Must be done last, see page 206 (1 => 4 Mhz clock rate)

    // Set Clock pin to output
    *SLAVE_MSPIM_DDR_REG |= SLAVE_MSPIM_SCK_PIN_MASK;
}


