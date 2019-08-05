// test_master.ino
//
// Trying out example by Nick Gammon (USART in SPI mode on the Atmega328)
// http://www.gammon.com.au/forum/?id=10892
//
// Notes
// ----------------------------------------------------------------------------
// The Arduino Pins are setup as follows:
//    (D0) MISO
//    (D1) MOSI
//    (D4) SCK
//    (D5) SS
//
// ----------------------------------------------------------------------------

enum {BUFFER_SIZE=255};
const uint8_t MSPIM_SCK = 4;
const uint8_t MSPIM_SS = 5;

uint8_t MSPIM_TransferByte(uint8_t value)
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


void MSPIM_WriteBuffer(uint8_t buffer[],uint8_t numBytes=BUFFER_SIZE)
{

    // Enable slave select
    digitalWrite (MSPIM_SS, LOW);

    // Transfer buffer
    for (uint8_t i=0; i<numBytes; i++)
    {
        MSPIM_TransferByte(buffer[i]);
    }

    // Wait for all transmissions to finish
    while ((UCSR0A & _BV(TXC0)) == 0)
    {}

    // Disable slave select
    digitalWrite(MSPIM_SS, HIGH);
}

void setup()
{
    // Setup USART in SPI mode
    // ------------------------------------------------------------------------

    pinMode(MSPIM_SS,OUTPUT);
    UBRR0 = 0;                               // Must be zero before enabling the transmitter
    UCSR0A = _BV (TXC0);                     // any old transmit now complete 

    UCSR0C = _BV(UMSEL00) | _BV(UMSEL01);    // Master SPI mode
    UCSR0B = _BV(TXEN0)   | _BV(RXEN0);      // transmit enable and receive enable
    //UBRR0 = 3;                               // Must be done last, see page 206 (2 Mhz clock rate)
    UBRR0 = 1;                               // Must be done last, see page 206 (2 Mhz clock rate)

    pinMode(MSPIM_SCK, OUTPUT);              // Set XCK pin as output to enable master mode
    // ------------------------------------------------------------------------
}

void loop()
{
    uint8_t buffer[BUFFER_SIZE];
    static uint8_t cnt = 0;

    buffer[0] = BUFFER_SIZE;
    for (uint8_t i=1; i<BUFFER_SIZE; i++)
    {
        buffer[i] = i-1;
    }

    MSPIM_WriteBuffer(buffer, BUFFER_SIZE);

    cnt++;
    delay(500);
}
