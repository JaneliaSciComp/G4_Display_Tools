#ifndef UTILS_H
#define UTILS_H
#include "constants.h"


class Buffer
{
    public:
        Buffer();
        void clear();
        inline void insert(uint8_t value);
        uint8_t data[BUFFER_SIZE];
        uint8_t dataLen;
        bool dataReady;
        bool errorFlag;
};

inline void Buffer::insert(uint8_t value)
{
    if (dataLen < (BUFFER_SIZE-1))
    {
        data[dataLen] = value;
        dataLen++;
    }
    else
    {
        errorFlag = true;
    }
}


void resetAllSlaves();
void initSlaveResetPins();

inline uint8_t getBufferMsgSize(Buffer &buffer)
{ 
    uint8_t pwmType = buffer.data[0] & PWM_TYPE_MASK; 
    if (pwmType == PWM_TYPE_16)
    {
        return PWM_TYPE_16_MSG_SIZE;
    }
    else
    {
        return PWM_TYPE_2_MSG_SIZE;
    }
}

#endif
