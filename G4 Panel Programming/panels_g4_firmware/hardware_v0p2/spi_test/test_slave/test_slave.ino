#include <Streaming.h>

enum {BUFFER_SIZE=255};

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


void setup()
{
    Serial.begin(115200);

    // Setup SPI communications
    pinMode(MISO,OUTPUT);
    pinMode(SS, INPUT);
    SPCR |= _BV(SPE);

    // Turn off interrupts
    //noInterrupts(); 
}


void loop()
{
    static SpiBuffer buffer = SpiBuffer();
    static unsigned int cnt = 0;
    uint8_t spiMsgSize;

    noInterrupts(); 
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
            spiMsgSize = buffer.data[0]; 
        }
        if (buffer.dataLen >= spiMsgSize)
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
    interrupts();

    // Check SPI message
    // --------------------------------------------------
    bool ok = true;
    if (buffer.dataReady)
    {
        for (int i=1; i<buffer.dataLen; i++)
        {
            if (buffer.data[i] != i-1)
            {
                ok = false;
            }
        }
        Serial << "ok: " << ok << ", cnt = " << cnt << endl;
        cnt++;
    }
    buffer.clear();

}

