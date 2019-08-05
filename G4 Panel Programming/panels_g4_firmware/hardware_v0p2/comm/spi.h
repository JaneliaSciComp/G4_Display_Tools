#ifndef SPI_H
#define SPI_H
#include <Arduino.h>
#include "utils.h"

void SPI_Initialize();

void SPI_ReceiveMsg(Buffer &buffer);

#endif
