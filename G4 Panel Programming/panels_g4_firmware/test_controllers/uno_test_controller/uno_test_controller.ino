// ----------------------------------------------------------------------------
// uno_test_controller.ino - Simple demo panels G4 controller for Arduino Uno
//
// ----------------------------------------------------------------------------
#include <SPI.h>
#include <Streaming.h>


// Global constants
// ============================================================================

// SPI and and I2C communication parameters
//const uint8_t SPI_NUM_SLAVES = 8;                              // # panels which can be stacked 
const uint8_t SPI_NUM_SLAVES = 1;                                // # panels which can be stacked 
const uint8_t I2C_NUM_SLAVES = 4;                                // Four i2c slaves per panel
//const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {2,5,6,7,8,9,3,4};     // SPI chip select lines
//const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {2,4,5,6,7};             // SPI chip select lines
//const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {2,4,5};             // SPI chip select lines
const uint8_t SPI_PIN_ARRAY[SPI_NUM_SLAVES]  = {2};             // SPI chip select lines

const uint8_t I2C_TYPE_2_MSG_SIZE = 9;
const uint8_t I2C_TYPE_16_MSG_SIZE = 33;

const uint8_t SPI_TYPE_2_MSG_SIZE = 4*I2C_TYPE_2_MSG_SIZE;
const uint8_t SPI_TYPE_16_MSG_SIZE = 4*I2C_TYPE_16_MSG_SIZE;

// Special pins - must be inputs as overlap with spi pins on modified colorimeter shield
const uint8_t NUM_SPECIAL_PINS = 2;
const uint8_t SPECIAL_PIN_ARRAY[NUM_SPECIAL_PINS] = {8,9};

// Message contruction parametes 
const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;
const uint8_t DELAY_VALUE_TYPE_16 = 0;
const uint8_t DELAY_VALUE_TYPE_2 = 35;

// PWM type identifiers
const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint8_t PWM_TYPE_MASK = 0x01;

// Counter used for updating to next pattern in buffer  - sets stripe speed.
//const uint16_t PWM_UPDATE_CNT_TYPE_16 = 15;  
const uint16_t PWM_UPDATE_CNT_TYPE_16 = 30;  
const uint16_t PWM_UPDATE_CNT_TYPE_2 = 100;  

// Display configuration parameters
const uint8_t MATRIX_NUM_ROW = 8;
const uint8_t MATRIX_NUM_COL = 8;
const uint8_t PANEL_NUM_ROW = 2*MATRIX_NUM_ROW;

// Message buffer array parameters
const uint8_t BUFFER_ARRAY_SIZE = 9;
const uint8_t ALL_ZEROS_BUF_IND = 8;

// Timing parameters
//const uint16_t LOOP_DELAY_TYPE_16 = 310; // us
//const uint16_t LOOP_DELAY_TYPE_16 = 20;   // us
const uint16_t LOOP_DELAY_TYPE_16 =  300;   // us
const uint16_t LOOP_DELAY_TYPE_2 =  150;    // us
//const uint16_t LOOP_DELAY_TYPE_2 =  65;    // us

// Demo pwm type
const uint8_t DEMO_PWM_TYPE = PWM_TYPE_16;
//const uint8_t DEMO_PWM_TYPE = PWM_TYPE_2;

// Synchronization parameters
const uint8_t SYNC_TYPE_MASTER = 0;
const uint8_t SYNC_TYPE_SLAVE = 1;
const uint8_t SYNC_TYPE = SYNC_TYPE_MASTER;
//const uint8_t SYNC_TYPE = SYNC_TYPE_SLAVE;
const uint8_t SYNC_PIN = 3;
volatile bool syncFlag = false;


// Function prototypes
// ============================================================================

// Display update demo functions
inline void type16DisplayUpdate();
inline void type2DisplayUpdate();

// Functions for createing demo type 16 buffers and matrices (16-level grayscale)
void createType16_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_16_MSG_SIZE],
    uint8_t bufferArraySize,
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t)
    );

void zeroType16_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_16_MSG_SIZE],
    uint8_t bufferArraySize
);

uint8_t getType16StripeMatrix(uint8_t bufNum, uint8_t row, uint8_t col);


// Functions for createign demo type 2 buffers and matrices (2-level grayscale)
void createType2_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_2_MSG_SIZE],
    uint8_t bufferArraySize,
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t)
    );

void zeroType2_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_2_MSG_SIZE],
    uint8_t bufferArraySize
    );

uint8_t getType2StripeMatrix(uint8_t bufNum, uint8_t row, uint8_t col);

void onSyncPulse();

// Arduino entry point functions 
// ============================================================================

void setup()
{
    Serial.begin(115200);
    // Set Special (hardware overlapping) pins to inputs - so they don't 
    // interfere with SPI communications. This is due to re-use (re-wiring) of
    // colorimeter Arduino shield.
    for (uint8_t pinNum=0; pinNum<NUM_SPECIAL_PINS; pinNum++)
    {
        pinMode(SPECIAL_PIN_ARRAY[pinNum], INPUT);
    }

    // Initialize SPI communications
    for (uint8_t spiSlave=0; spiSlave < SPI_NUM_SLAVES; spiSlave++)
    { 
        pinMode(SPI_PIN_ARRAY[spiSlave], OUTPUT);
        digitalWrite(SPI_PIN_ARRAY[spiSlave], HIGH);
    }
    SPI.begin();
    SPI.setClockDivider(SPI_CLOCK_DIV4);

    if (SYNC_TYPE == SYNC_TYPE_MASTER)
    {
        pinMode(SYNC_PIN,OUTPUT);
        digitalWrite(SYNC_PIN,LOW);
        delay(1000);
    }
    else
    {
        pinMode(SYNC_PIN,INPUT);
        attachInterrupt(1,onSyncPulse,RISING);
    }

}

void loop()
{
    if (SYNC_TYPE == SYNC_TYPE_MASTER)
    {
        digitalWrite(SYNC_PIN, HIGH);
        delayMicroseconds(200);
        digitalWrite(SYNC_PIN,LOW);
    }
    else
    {
        while (!syncFlag) {};
        syncFlag = false;
    }

    if (DEMO_PWM_TYPE == PWM_TYPE_16)
    {
        type16DisplayUpdate();
    }
    else
    {
        type2DisplayUpdate();
    }
}

// Display update demos
// ============================================================================

void onSyncPulse()
{
    syncFlag = true;
}

void type16DisplayUpdate()
{
    static uint8_t bufferArray[BUFFER_ARRAY_SIZE][I2C_TYPE_16_MSG_SIZE];
    static uint8_t slaveToBufIndMap[I2C_NUM_SLAVES];
    static uint8_t stripeRow = 0;
    static uint16_t updateCnt = 0;
    static bool isFirst = true;

    // Create display patterns 
    if (isFirst)
    {
        // Notes, buffers n for n=0,... ,7 contains a stripe in row n. 
        // Buffer 8 contains empty pattern
        zeroType16_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE);
        createType16_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE,getType16StripeMatrix);
        isFirst = false;
    }

    // Get I2C slave to buffer index mapping based on strip position - too slow for inner loop
    for (uint8_t i2cSlave=0; i2cSlave<I2C_NUM_SLAVES; i2cSlave++)
    { 
        slaveToBufIndMap[i2cSlave] = stripeRow%MATRIX_NUM_ROW;
        //if (stripeRow < PANEL_NUM_ROW/2)
        //{
        //    if ((i2cSlave==0) || i2cSlave==2)
        //    {
        //        slaveToBufIndMap[i2cSlave] = ALL_ZEROS_BUF_IND; 
        //    }
        //} 
        //else
        //{
        //    if ((i2cSlave==1) || (i2cSlave==3))
        //    {
        //        slaveToBufIndMap[i2cSlave] = ALL_ZEROS_BUF_IND; 
        //    }
        //}
    }

    // Send SPI message
    for (uint8_t spiSlave=0; spiSlave<SPI_NUM_SLAVES; spiSlave++)
    {
        bool flag = true;

        digitalWrite(SPI_PIN_ARRAY[spiSlave], LOW);
        // Send copy of I2C Message (over SPI) for each i2c slave
        for (uint8_t i2cSlave=0; i2cSlave < I2C_NUM_SLAVES; i2cSlave++)
        {
            for (uint8_t i=0; i<I2C_TYPE_16_MSG_SIZE; i++)
            {
                uint8_t bufInd = slaveToBufIndMap[i2cSlave];
                uint8_t spiRsp = SPI.transfer(bufferArray[bufInd][i]);

                // Note, for i>0 you can check for spiRsp == bufferArray[bufInd][i-1]
                // if not true something is wrong - panel is not responding.
            }
        }
        digitalWrite(SPI_PIN_ARRAY[spiSlave], HIGH);
    }

    // Update pattern information
    updateCnt++;
    if (updateCnt%PWM_UPDATE_CNT_TYPE_16 == 0)
    {
        stripeRow = (stripeRow + 1)%PANEL_NUM_ROW;
    }

    if ( (LOOP_DELAY_TYPE_16 > 0) && (SYNC_TYPE==SYNC_TYPE_MASTER) )
    { 
        delayMicroseconds(LOOP_DELAY_TYPE_16);
    }
}

void type2DisplayUpdate()
{
    static uint8_t bufferArray[BUFFER_ARRAY_SIZE][I2C_TYPE_2_MSG_SIZE];
    static uint8_t slaveToBufIndMap[I2C_NUM_SLAVES];
    static uint8_t stripeRow = 0;
    static uint16_t updateCnt = 0;
    static bool isFirst = true;

    // Create display patterns 
    if (isFirst)
    {
        // Notes, buffers n for n=0,... ,7 contains a stripe in row n. 
        // Buffer 8 contains empty pattern
        zeroType2_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE);
        createType2_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE,getType2StripeMatrix);
        isFirst = false;
    }

    // Get I2C slave to buffer index mapping based on strip position - too slow for inner loop
    for (uint8_t i2cSlave=0; i2cSlave<I2C_NUM_SLAVES; i2cSlave++)
    { 
        slaveToBufIndMap[i2cSlave] = stripeRow%MATRIX_NUM_ROW;
        if (stripeRow < PANEL_NUM_ROW/2)
        {
            if ((i2cSlave==0) || i2cSlave==1)
            {
                slaveToBufIndMap[i2cSlave] = ALL_ZEROS_BUF_IND; 
            }
        } 
        else
        {
            if ((i2cSlave==2) || (i2cSlave==3))
            {
                slaveToBufIndMap[i2cSlave] = ALL_ZEROS_BUF_IND; 
            }
        }
    }

    // Send SPI message
    for (uint8_t spiSlave=0; spiSlave<SPI_NUM_SLAVES; spiSlave++)
    {
        digitalWrite(SPI_PIN_ARRAY[spiSlave], LOW);

        // Send copy of I2C Message (over SPI) for each i2c slave
        for (uint8_t i2cSlave=0; i2cSlave < I2C_NUM_SLAVES; i2cSlave++)
        {
            for (uint8_t i=0; i<I2C_TYPE_2_MSG_SIZE; i++)
            {
                uint8_t bufInd = slaveToBufIndMap[i2cSlave];
                SPI.transfer(bufferArray[bufInd][i]);
            }
        }
        digitalWrite(SPI_PIN_ARRAY[spiSlave], HIGH);
    }

    // Update pattern information
    updateCnt++;
    if (updateCnt%PWM_UPDATE_CNT_TYPE_2 == 0)
    {
        stripeRow = (stripeRow + 1)%PANEL_NUM_ROW;
    }

    if ((LOOP_DELAY_TYPE_2 > 0) && (SYNC_TYPE == SYNC_TYPE_MASTER))
    {
        delayMicroseconds(LOOP_DELAY_TYPE_2);
    }
}

// Buffer array creation functions
// ============================================================================

// createType16_I2CBufferArray
// ----------------------------------------------------------------------------
// 
// Creates an array of I2C buffer containing 'TYPE_16' (16-level grasy scale)  
// display matrix data where the display data is determined by the specified 
// matrixFunc function. 
//
// Arguments:
// 
// bufferArray      =  array of display buffers. 
// bufferArraySize  =  size of display buffer array.
// matrixFunc       =  function for specifying display data. Siganture
// 
// Notes:
// matrixFunc should have the following signature.                   
// 
//   value = matrixFunc(uint8_t bufNum, uint8_t row, uint8_t col)
//
// returns display value for specified buffer number bufNum, row, and col.
// 
// --------------------------------------------------------------------------
void createType16_I2CBufferArray( 
    uint8_t bufferArray[][I2C_TYPE_16_MSG_SIZE],
    uint8_t bufferArraySize,
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t)
    )
{
    uint8_t delayValue = DELAY_VALUE_TYPE_16;
    zeroType16_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE);
    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        uint8_t ind = 0;
        bufferArray[bufNum][ind] = PWM_TYPE_16 + (delayValue << DELAY_SHIFT);
        for (uint8_t row=0; row<MATRIX_NUM_ROW; row++)
        {
            for (uint8_t col=0; col<MATRIX_NUM_COL; col++)
            {
                ind = 4*row + col/2 + 1;
                uint8_t  val = matrixFunc(bufNum, row, col);
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


// zeroType16_I2CBufferArray
// ----------------------------------------------------------------------------
// 
// Zeros an array of I2C buffer containing 'TYPE_16' (16-level grasy scale)  
// display matrix data. 
//
// Arguments:
// 
// bufferArray      =  array of display buffers. 
// bufferArraySize  =  size of display buffer array.
//
// ----------------------------------------------------------------------------
void zeroType16_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_16_MSG_SIZE],
    uint8_t bufferArraySize
)
{
    uint8_t delayValue = DELAY_VALUE_TYPE_16;
    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        bufferArray[bufNum][0] = PWM_TYPE_16 + (delayValue << DELAY_SHIFT);
        for (int i=1; i<I2C_TYPE_16_MSG_SIZE; i++)
        {
            bufferArray[bufNum][i] = 0;
        }
    }
}


// getType16StripeMatrix
// ----------------------------------------------------------------------------
// 
// Returns display matrix pixel value where the pixels in row == bufNum are 
// active (value == 0xf) and all other pixels are off (value == 0).
//
// ----------------------------------------------------------------------------
uint8_t getType16StripeMatrix(uint8_t bufNum, uint8_t row, uint8_t col)
{
    if (bufNum == ALL_ZEROS_BUF_IND)
    {
        return 0;
    }
    //return 0xf;

    if (row==bufNum)
    {
        return 0xf;  // on - full brightness
        //return 0x1;  // on - full brightness
        //return 0;  // on - full brightness
    }
    else
    { 
        return 0;   // off 
        //return 0xf;
    }

    //if (col==bufNum)
    //{
    //    return 0xf;
    //}
    //else
    //{
    //    return 0x0;
    //}
}


// createType2_I2CBufferArray
// ----------------------------------------------------------------------------
//
// Creates an array of I2C buffer containing 'TYPE_2' (22-level grasy scale)  
// display matrix data where the display data is determined by the specified 
// matrixFunc function. 
//
// Arguments:
// 
// bufferArray      =  array of display buffers. 
// bufferArraySize  =  size of display buffer array.
// matrixFunc       =  function for specifying display data. Siganture
// 
// Notes:
// matrixFunc should have the following signature.                   
// 
//   value = matrixFunc(uint8_t bufNum, uint8_t row, uint8_t col)
//
// returns display value for specified buffer number bufNum, row, and col.
// 
// --------------------------------------------------------------------------
void createType2_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_2_MSG_SIZE],
    uint8_t bufferArraySize,
    uint8_t (*matrixFunc)(uint8_t, uint8_t, uint8_t)
    )
{
    uint8_t delayValue = DELAY_VALUE_TYPE_2;
    zeroType2_I2CBufferArray(bufferArray,BUFFER_ARRAY_SIZE);
    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        uint8_t ind = 0;
        bufferArray[bufNum][ind] = PWM_TYPE_2 + (delayValue << DELAY_SHIFT);
        for (uint8_t row=0; row<MATRIX_NUM_ROW; row++)
        {
            for (uint8_t col=0; col<MATRIX_NUM_COL; col++)
            {
                ind = row + 1;
                uint8_t  val = matrixFunc(bufNum, row, col);
                bufferArray[bufNum][ind] |= ( (val & 0x1) << col);
            }
        }
    }
}

// zeroType2_I2CBufferArray
// ----------------------------------------------------------------------------
// 
// Zeros an array of I2C buffer containing 'TYPE_2' (2-level grasy scale)  
// display matrix data. 
//
// Arguments:
// 
// bufferArray      =  array of display buffers. 
// bufferArraySize  =  size of display buffer array.
//
// ----------------------------------------------------------------------------
void zeroType2_I2CBufferArray(
    uint8_t bufferArray[][I2C_TYPE_2_MSG_SIZE],
    uint8_t bufferArraySize
    )
{
    uint8_t delayValue = DELAY_VALUE_TYPE_2;
    for (uint8_t bufNum=0; bufNum<bufferArraySize; bufNum++)
    {
        bufferArray[bufNum][0] = PWM_TYPE_2 + (delayValue << DELAY_SHIFT);
        for (int i=1; i<I2C_TYPE_2_MSG_SIZE; i++)
        {
            bufferArray[bufNum][i] = 0;
        }
    }
}

// getType2StripeMatrix
// ----------------------------------------------------------------------------
// 
// Returns display matrix pixel value where the pixels in row == bufNum are 
// active (value == 1) and all other pixels are off (value == 0).
//
// ----------------------------------------------------------------------------
uint8_t getType2StripeMatrix(uint8_t bufNum, uint8_t row, uint8_t col)
{
    if (bufNum == row)
    {
        return 0x1;
    }
    else
    {
        return 0x0;
    }
}
