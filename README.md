# XLR8DMem

Use the read and write functions of XLR8DMem to access memory blocks
on an Alorium board built with the XLR8DMem XB.

This is generally intended for use with an Alorium Hinj board running 
an image built with the XLR8DMem XB, and will not work on an XLR8 or 
Sno unless you adapt a custom image for it.

Include the header file in your Arduino sketch.

Access reads via XLR8DMem.read(address, data, length, stride), where
address is a 16 bit address of the starting memory location, data is a
pointer to an 8 bit data container, length is an integer of the length
of 8 bit segments to read into data (optional, defaults to a length of
1 if not provided), and stride is an integer representing the stride
length between reads (optional, defaults to a stride of 1 if not
provided).

Access writes via XLR8DMem.write(address, data, length, stride), where
address is a 16 bit address of the starting memory location, data is a
pointer to an 8 bit data container, length is an integer of the length
of 8 bit segments to read into data (optional, defaults to a length of
1 if not provided), and stride is an integer representing the stride
length between reads (optional, defaults to a stride of 1 if not
provided).

When implementing the XMR8DMem XB in OpenXLR8, this XB is can be
configured for any size between 1KB and 64KB, in 1KB increments. When
instantiating the xlr8_dmem_xb module in openxlr8, set the value of
XLR8DMEM_SIZE to the number of KB of DMem desired. See the example
openxlr8.v included in this library.



