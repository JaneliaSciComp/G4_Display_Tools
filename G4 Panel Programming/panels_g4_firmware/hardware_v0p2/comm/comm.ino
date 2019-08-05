#include <SPI.h>
#include "constants.h"
#include "utils.h"
#include "spi.h"
#include "mspim_spi.h"


void setup()
{
    initSlaveResetPins();
    resetAllSlaves();
    SPI_Initialize();    
    MSPIM_Initialize();  
    noInterrupts(); 
}


void loop()
{
    static Buffer buffer;
    SPI_ReceiveMsg(buffer);
    MSPIM_SendDataToSlaves(buffer);
    buffer.clear();
}




