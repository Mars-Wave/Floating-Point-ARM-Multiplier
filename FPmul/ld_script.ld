SECTIONS
{
    . = 0x0C100000;
    .data : {
      *(.data*)
      *(.rodata*) 
    }
	Image_ZI_Base = .;
    .bss : { 
      *(.bss*)
      *(COMMON)
    }
	Image_ZI_Limit = .;
    .text : { 
      *(.text*)
    }
    PROVIDE( end = . );
    PROVIDE(_stack = 0x0C7FF000 );   
}