#include <SPI.h>

// Global constants
// --------------------------------------------------------------------------------------
//const int ssPin = 4;
const uint8_t SPI_CLOCK_DIV = 21;
//const uint8_t SPI_NUM_SLAVES = 4;
//const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {4,10,52,7};
const uint8_t SPI_NUM_SLAVES = 1;
const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {4};
const uint8_t I2C_NUM_SLAVES=4;
const uint8_t I2C_TYPE_2_MSG_SIZE = 9;
const uint8_t SPI_TYPE_2_MSG_SIZE = 4*I2C_TYPE_2_MSG_SIZE;
const uint8_t I2C_TYPE_16_MSG_SIZE = 33;
const uint8_t SPI_TYPE_16_MSG_SIZE = 4*I2C_TYPE_16_MSG_SIZE;

const uint8_t PWM_TYPE_MASK = 0x01;
const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint16_t PWM_UPDATE_CNT = 100; 

const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;
const uint8_t MATRIX_NUM_ROW = 8;

const uint8_t MATRIX_NUM_COL = 8;
const uint8_t BUFFER_ARRAY_SIZE = 16;

const uint16_t LOOP_DELAY = 1510;


// Function prototypes
// --------------------------------------------------------------------------------------
void createType16BufferArray(
    uint8_t bufferArray[][SPI_TYPE_16_MSG_SIZE], 
    uint8_t bufferArraySize, 
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t, uint8_t)
    );

void zeroType16BufferArray(
    uint8_t bufferArray[][SPI_TYPE_16_MSG_SIZE], 
    uint8_t bufferArraySize 
    );

uint8_t getConstType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col);
uint8_t getRowStripeType16Matrix(uint8_t  bufNum, uint8_t slaveNum, uint8_t row, uint8_t col);
uint8_t getColFillType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col);
uint8_t getDiagFillType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col);


// Arduino functions 
// --------------------------------------------------------------------------------------

void setup()
{
    // Initialize SPI communications
    for (uint8_t slave=0; slave < SPI_NUM_SLAVES; slave++)
    {
        if (slave <=2)
        {
            // Hardware spi pins
            SPI.begin(SPI_PIN_ARRAY[slave]);
            SPI.setClockDivider(SPI_PIN_ARRAY[slave], SPI_CLOCK_DIV);
        }
        else
        {
            // Manual SPI pins
            pinMode(SPI_PIN_ARRAY[slave], OUTPUT);
            digitalWrite(SPI_PIN_ARRAY[slave], HIGH);
        }
    }
    SPI.begin();
    SPI.setClockDivider(SPI_CLOCK_DIV);
}

void loop()
{
    static bool isFirst = true;
    static uint8_t bufferArray[BUFFER_ARRAY_SIZE][SPI_TYPE_16_MSG_SIZE];
    static uint8_t bufNum = 0;
    static uint16_t updateCnt = 0;

    // Create display patterns 
    if (isFirst)
    {
        zeroType16BufferArray(bufferArray,BUFFER_ARRAY_SIZE);
        //createType16BufferArray(bufferArray,BUFFER_ARRAY_SIZE,getRowStripeType16Matrix);
        createType16BufferArray(bufferArray,BUFFER_ARRAY_SIZE,getColFillType16Matrix);
        //createType16BufferArray(bufferArray,BUFFER_ARRAY_SIZE,getDiagFillType16Matrix);
        isFirst = false;
    }

    // Write pattern data to SPI slaves
    for (uint8_t slave=0; slave < SPI_NUM_SLAVES; slave++)
    {
        if (slave > 2)
        {
            digitalWrite(SPI_PIN_ARRAY[slave],LOW);
        }
        for (uint8_t i=0; i<SPI_TYPE_16_MSG_SIZE-1; i++)
        {
            if (slave <= 2)
            {
                SPI.transfer(SPI_PIN_ARRAY[slave], bufferArray[bufNum][i], SPI_CONTINUE);
            }
            else
            {
                SPI.transfer(bufferArray[bufNum][i]);
            }
        } 
        if (slave <= 2)
        {
            SPI.transfer(SPI_PIN_ARRAY[slave], bufferArray[bufNum][SPI_TYPE_16_MSG_SIZE-1], SPI_LAST);
        }
        else
        {
            SPI.transfer(bufferArray[bufNum][SPI_TYPE_16_MSG_SIZE-1]);
            digitalWrite(SPI_PIN_ARRAY[slave],HIGH);
        }
    }

    // Update pattern information
    updateCnt++;
    if (updateCnt%PWM_UPDATE_CNT == 0)
    {
        bufNum = (bufNum + 1)%BUFFER_ARRAY_SIZE;
    }

    delayMicroseconds(LOOP_DELAY);
}


// Buffer array creation functions
// ----------------------------------------------------------------------------
void createType16BufferArray(
    uint8_t bufferArray[][SPI_TYPE_16_MSG_SIZE], 
    uint8_t bufferArraySize, 
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t, uint8_t)
    )
{
    uint8_t delayValue = 0;
    uint8_t ind;

    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        for (uint8_t slave=0; slave<I2C_NUM_SLAVES; slave++)
        {
            ind = I2C_TYPE_16_MSG_SIZE*slave;
            bufferArray[bufNum][ind] = PWM_TYPE_16 + (delayValue << DELAY_SHIFT); 

            for (uint8_t row=0; row<MATRIX_NUM_ROW; row++)
            {
                for (uint8_t col=0; col<MATRIX_NUM_COL; col++)
                {
                    ind = I2C_TYPE_16_MSG_SIZE*slave + 4*row +col/2 + 1;
                    uint8_t val = matrixFunc(bufNum, slave, row, col); 
                    if (col%2==0)
                    {
                        bufferArray[bufNum][ind] |= (val & 0x0f);
                    }
                    else
                    {
                        bufferArray[bufNum][ind] |= (val << 4);
                    }
                }
            }

        }
    }
}


void zeroType16BufferArray(
    uint8_t bufferArray[][SPI_TYPE_16_MSG_SIZE], 
    uint8_t bufferArraySize 
    )
{
    uint8_t delayValue = 0;
    uint8_t ind;

    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        for (uint8_t slave=0; slave<I2C_NUM_SLAVES; slave++)
        {
            ind = I2C_TYPE_16_MSG_SIZE*slave;
            bufferArray[bufNum][ind] = PWM_TYPE_16 + (delayValue << DELAY_SHIFT); 

            for (uint8_t row=0; row<MATRIX_NUM_ROW; row++)
            {
                for (uint8_t col=0; col<MATRIX_NUM_COL; col++)
                {
                    ind = I2C_TYPE_16_MSG_SIZE*slave + 4*row +col/2 + 1;
                    bufferArray[bufNum][ind] = 0;
                }
            }

        }
    }
}

// Display matrix creation functions
// --------------------------------------------------------------------------------------
uint8_t getConstType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col)
{
    return bufNum%16;
}

uint8_t getRowStripeType16Matrix(uint8_t  bufNum, uint8_t slaveNum, uint8_t row, uint8_t col)
{
    uint8_t bufNumMod16 = bufNum%16;
    uint8_t value = 0;

    if (bufNumMod16 < 8)
    {
        if ((slaveNum == 0) || (slaveNum == 1))
        {
            if (row==bufNumMod16)
            {
                value = 15;
            }
        }
    }
    else
    {
        if ((slaveNum == 2) || (slaveNum == 3))
        {
            if (row==(bufNumMod16-8))
            {
                value = 15;
            }
        }
    }
    return value;
}

uint8_t getColFillType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col)
{
    uint8_t bufNumMod8  = bufNum%8;
    uint8_t value = 0;

    if (col <= bufNumMod8)
    //if (col <= 7)
    {
        value = 15;
    }
    return value;
}

uint8_t getDiagFillType16Matrix(uint8_t bufNum, uint8_t slaveNum, uint8_t row, uint8_t col)
{
    uint8_t bufNumMod8 = bufNum%8;
    uint8_t value = 0;

    if (col <= row)
    {
        value = 15;
    }
    return value;
}
