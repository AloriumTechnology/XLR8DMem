/*--------------------------------------------------------------------
 Copyright (c) 2019 Alorim Technology.  All right reserved.
 This file is part of the Alorium Technology XLR8 DMem library.
 Written by Bryan Craker of Alorium Technology (info@aloriumtech.com).
   The XLR8 DMem library is built to take advantage of the FPGA 
   hardware acceleration available on the XLR8 board.


 Use the read and write functions of XLR8DMem to access memory blocks 
 on an Alorium board built with the XLR8DMem XB.

 This is generally intended for use with an Alorium Hinj board running
 an image built with the XLR8DMem XB, and will not work on an XLR8 or
 Sno unless you adapt a custom image for it.

 Access writes via XLR8DMem.write(address, data, length, stride), 
 where address is a 16 bit address of the starting memory location, 
 data is a pointer to an 8 bit data container, length is an integer 
 of the length of 8 bit segments to read into data (optional, 
 defaults to a length of 1 if not provided), and stride is an integer 
 representing the stride length between reads (optional, defaults to a 
 stride of 1 if not provided).

 Access reads via XLR8DMem.read(address, data, length, stride), where 
 address is a 16 bit address of the starting memory location, data is 
 a pointer to an 8 bit data container, length is an integer of the 
 length of 8 bit segments to read into data (optional, defaults to a 
 length of 1 if not provided), and stride is an integer representing 
 the stride length between reads (optional, defaults to a stride of 1 
 if not provided).


 This library is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as
 published by the Free Software Foundation, either version 3 of
 the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library.  If not, see
 <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------*/

#ifndef XLR8DMEM_H
#define XLR8DMEM_H

#include <stdint.h>
#include <avr/interrupt.h>

#define XLR8_DMEM_ADDR_REG   _SFR_MEM8(0xD9)
#define XLR8_DMEM_STRIDE_REG _SFR_MEM8(0xDA)
#define XLR8_DMEM_DATA_REG   _SFR_MEM8(0xDB)

namespace XLR8DMemLib {

class XLR8DMemClass
{
public:
  void write(uint16_t addr, uint8_t * data, int len = 1, int stride = 1);
  void read (uint16_t addr, uint8_t * data, int len = 1, int stride = 1);
};

extern XLR8DMemClass XLR8DMem;

};

using namespace XLR8DMemLib;

#endif // XLR8DMEM_H

