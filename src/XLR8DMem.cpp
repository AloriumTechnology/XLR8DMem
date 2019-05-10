#include "XLR8DMem.h"

XLR8DMemClass::XLR8DMemClass()
{
}

XLR8DMemClass::~XLR8DMemClass()
{
}

void XLR8DMemClass::write(uint16_t addr, uint8_t * data, int len, int stride)
{
  XLR8_DMEM_ADDR_REG = addr >> 8;
  XLR8_DMEM_ADDR_REG = addr;
  XLR8_DMEM_STRIDE_REG = stride;
  for (int idx = 0; idx < len; idx++) {
    XLR8_DMEM_DATA_REG = data[idx];
  }
}

void XLR8DMemClass::read(uint16_t addr, uint8_t * data, int len, int stride)
{
  XLR8_DMEM_ADDR_REG = addr >> 8;
  XLR8_DMEM_ADDR_REG = addr;
  XLR8_DMEM_STRIDE_REG = stride;
  for (int idx = 0; idx < len; idx++) {
    data[idx] = XLR8_DMEM_DATA_REG;
  }
}

XLR8DMemClass XLR8DMem;

