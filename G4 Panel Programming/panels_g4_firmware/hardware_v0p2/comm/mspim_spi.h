#ifndef MSPIM_SPI_H
#define MSPIM_SPI_H
#include "constants.h"
#include "utils.h"

void MSPIM_SendDataToSlaves(Buffer &buffer);

void MSPIM_WriteBuffer(uint8_t ssPinMask, Buffer &buffer, uint8_t ind0, uint8_t ind1);

void MSPIM_WriteBuffer(uint8_t ssPinMask, Buffer &buffer, uint8_t numBytes);

void MSPIM_Initialize();

inline uint8_t MSPIM_TransferByte(uint8_t value)
{
    // Wait for transmitter ready - i.e., wait for empty transmit buffer
    while ((UCSR0A & _BV(UDRE0)) == 0) 
    {}
    // send byte
    UDR0 = value;
    // Wait for receiver ready
    while ((UCSR0A & _BV(RXC0)) == 0)
    {}
    // Receive byte, return it
    return UDR0;
}

#endif

