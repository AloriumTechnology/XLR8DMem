/*--------------------------------------------------------------------
 Copyright (c) 2019 Alorim Technology.  All right reserved.
 This file is part of the Alorium Technology XLR8 DMem library.
 Written by Bryan Craker of Alorium Technology (info@aloriumtech.com).
   The XLR8 DMem library is built to take advantage of the FPGA 
   hardware acceleration available on the XLR8 board.

 This example demonstrates functionality of the XLR8DMem. If the 
 XLR8DMem is built onto the target board, the following sketch will 
 write the string to XLR8DMem, then read the data back into the 
 returned variable. If the sketch runs properly you will see the 
 following output on Serial:

    Starting Value: Overwrite!
    Ending Value: Hello DMem

--------------------------------------------------------------------*/

#include <XLR8DMem.h>

uint16_t address = 30;
char * string = "Hello DMem";
char * returned = "Overwrite!";

void setup() {
  Serial.begin(115200);
  Serial.print("Starting Value: ");
  Serial.println(returned);
  XLR8DMem.write(address, string, strlen(string));
  XLR8DMem.read(address, returned, strlen(string));
  Serial.print("Ending Value: ");
  Serial.println(returned);
}

void loop() {}

