#ifndef CONSTANTS_H
#define CONSTANTS_H
#include <Arduino.h>

#define NOP __asm__ __volatile__ ("nop\n\t")

enum {NUM_SLAVE=4};
enum {BUFFER_SIZE=255};

extern const uint8_t PWM_TYPE_2;
extern const uint8_t PWM_TYPE_16;
extern const uint8_t PWM_TYPE_MASK;
extern const uint8_t PWM_TYPE_2_MSG_SIZE; 
extern const uint8_t PWM_TYPE_16_MSG_SIZE;
extern const uint8_t DELAY_MASK;
extern const uint8_t DELAY_SHIFT;

extern const uint8_t SLAVE_RESET_PIN_MASK; 
extern volatile uint8_t *SLAVE_RESET_OUT_REG;
extern volatile uint8_t *SLAVE_RESET_DDR_REG;

extern const uint8_t SLAVE_MSPIM_SS_PIN_MASK[NUM_SLAVE]; 
extern const uint8_t SLAVE_MSPIM_SCK_PIN_MASK;
extern volatile uint8_t *SLAVE_MSPIM_OUT_REG;
extern volatile uint8_t *SLAVE_MSPIM_DDR_REG;

#endif
