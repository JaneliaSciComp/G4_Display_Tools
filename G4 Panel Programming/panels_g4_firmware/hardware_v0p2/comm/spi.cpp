#include "spi.h"
#include <Arduino.h>

static uint8_t misoMask; 
static uint8_t misoPort;
static volatile uint8_t *misoModeReg; 
static volatile uint8_t *misoOutReg;

void SPI_Initialize()
{
    misoMask = digitalPinToBitMask(MISO);
    misoPort = digitalPinToPort(MISO);
    misoModeReg = portModeRegister(misoPort);
    misoOutReg = portOutputRegister(misoPort);

    //pinMode(MISO,OUTPUT);
    *misoModeReg &= ~misoMask;
    *misoOutReg &= ~misoMask;
    pinMode(SS, INPUT);
    SPCR |= _BV(SPE);
}

void SPI_ReceiveMsg(Buffer &buffer)
{

    // Spin loop for receiving SPI messages
    uint8_t msgSize;

    while (!(SPSR & _BV(SPIF)));
    *misoModeReg |= misoMask;
    while (true)
    {
        // Read byte from spi data register
        buffer.data[buffer.dataLen] = SPDR;
        buffer.dataLen++;
        if (buffer.dataLen == 1)
        {
            msgSize = getBufferMsgSize(buffer);
        }
        if (buffer.dataLen == 4*msgSize)
        {
            buffer.dataReady = true;
            break;
        }
        // DEBUG
        // ----------------------
        //SPDR = 0x0;
        // ----------------------
        while (!(SPSR & _BV(SPIF)));
    }
    *misoModeReg &= ~misoMask;
    *misoOutReg &= ~misoMask;
    while (digitalRead(SS) == 0); // Slow replace with direct port read

    // Read SPSR and SPDR a couple times - to clear out any possible mismatch 
    for (uint8_t i=0; i<5; i++)
    {
        uint8_t dummy0 = SPSR & _BV(SPIF);
        uint8_t dummy1 = SPDR;
    }
}

