                                     #include "constants.h"
#include <Arduino.h>

const uint8_t PWM_TYPE_2 = 0;
const uint8_t PWM_TYPE_16 = 1;
const uint8_t PWM_TYPE_MASK = 0x01;
const uint8_t PWM_TYPE_2_MSG_SIZE = 9;
const uint8_t PWM_TYPE_16_MSG_SIZE = 33;
const uint8_t DELAY_MASK = 0xfe;
const uint8_t DELAY_SHIFT = 1;

const uint8_t SLAVE_RESET_PIN_MASK = _BV(0) | _BV(1) | _BV(2) | _BV(3);
volatile uint8_t *SLAVE_RESET_OUT_REG = &PORTC;
volatile uint8_t *SLAVE_RESET_DDR_REG = &DDRC;

const uint8_t SLAVE_MSPIM_SS_PIN_MASK[NUM_SLAVE] = {_BV(3), _BV(5), _BV(6), _BV(7)};
const uint8_t SLAVE_MSPIM_SCK_PIN_MASK = _BV(4);
volatile uint8_t *SLAVE_MSPIM_OUT_REG = &PORTD;
volatile uint8_t *SLAVE_MSPIM_DDR_REG = &DDRD;
