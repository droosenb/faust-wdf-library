# faust-wdf-library

This library is intended for use for creating Wave Digital Filter (WDF) based models of audio circuitry for real-time audio processing within the Faust programming language. The goal is to provide a framework to create real-time virtual-analog audio effects and synthesizers using WDF models without the use of C++. Furthermore, we seek to provide access to the technique of WDF modeling to those without extensive knowledge of advanced digital signal processing techniques. Finally, we hope to provide a library which can integrate with all aspects of Faust, thus creating a platform for virtual circuit bending. 

The library itself is written in Faust to maintain portability. 

For detailed documentation, please see the SMC 2021 Paper, "A Wave-Digitial Filter Modeling Library for the Faust Programming Language." 

This library is heavily based on Kurt Werner's Dissertation, "Virtual Analog Modeling of Audio Circuitry Using Wave Digital Filters." I have tried to maintain consistent notation between the adaptors appearing within thesis and my adaptor code. The majority of the adaptors found in chapter 1 and chapter 3 are currently supported. 

For inquires about use of this library in a commercial product, please contact dirk [dot] roosenburg [dot] 30 [at] gmail [dot] com



## Acknowledgements

Many thanks to Kurt Werner for helping me to understand wave digital filter models. Without his publications and consultations, the library would not exist. 
Thanks also to my advisors, Rob Owen and Eli Stine whose input was critical to the development of the library.
Finally, thanks to Romain Michon, Stephane Letz, and the Faust slack for contributing to testing, development, and inspiration when creating the library. 

