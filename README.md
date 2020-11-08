# faust-wdf-library

This library is intended for use for creating Wave Digital Filter (WDF) based models of audio circuitry for real-time audio processing within the Faust programming language.
The library itself is written in Faust to maintain portability. 

Currently the library is in the early testing stages. Eventually, I hope to integrate it into the Faust Libraries project. 

This library is heavily based on Kurt Werner's Disertation, "Virtual Analog Modeling of Audio Cicuitry Using Wave Digital Filters." I have tried to maintain consistent notation between the adaptors appearing within thesis and my adaptor code. The majority of the adaptors found in chapter 1 and chapter 3 are currently supported. 

For inquires about use of this library in a commercial product, please contact dirk [dot] roosenburg [dot] 30 [at] gmail [dot] com

### Using this Library

Use of this library expects some level of famaliraity with WDF techniques, especially simplification and decomposition of electronic circuits into WDF tree structures. I plan to create video to cover both these techniques and use of the library. 

#### Quick Start

to get a quick overview of the library, start with the `secondOrderFilters.dsp` code found in `examples`. Make sure that the `wavedigitalfilters.lib` is within the compile path. This can be achieved within the [online Faust IDE](https://faustide.grame.fr/) by simply downloading and dragging in `wavedigitalfilters.lib` in addition to the example code.

#### Basic Modeling

Creating a model using this library consists fo three steps. First, declare a set of components. Second, model the relationship between them using a tree. Finally, build the tree using the libraries build functions.  

First, a set of components is declared using adaptors from the library.  This list of components is created based on analysis of the circuit using WDF techniques, though generally each circuit element (resistor, capacitor, diode, etc.) can be expected to apear within the component set. For example, first order RC lowpass filter would require an unadapted voltage source, a 47k resistor, and a 10nF capacitor which outputs the voltage across itself. These can be declared with: 

```
vs1(i) = wd.u_voltage(i, no.noise);
r1(i) = wd.resistor(i, 47*10^3);
c1(i) = wd.capacitor_output(i, 10*10^-9);
```

Note that the first argument, i, is left unparametrized. Components must be declared in this form, as the build algorithm expects to recieve adaptors which have exactly one parameter. 

Also note that we have chosen to declare a white noise function as the input to our voltage source. We could potentially declare this as a direct input to our model, but to do so is more complicated process which cannot be covered within this tutorial. In the future, I hope to support more simple declaration of direct inputs. 

Second, the declared components and interconnection/structural adaptors (i.e. series, parallel, etc) are arranged into the tree structure which is produced from performing WDF analyisis on the modeled circuit. For example, to produce our first order RC lowpass circuit model, the following tree is declared: 

`tree_lowpass = vs1(i) : wdf.series : (r1, c1)`

For more information on how to repersent trees in Faust, see Tree Structures in Faust. 

Finally, the tree is built using the the `buildtree` function. To build and compute our first order RC lowpass circuit model, we use

`process = buildtree(tree_lowpass);`

More information about build functions can be found in the documenatation within the library itself. 

#### Tree Structures in Faust

Since WDF models use tree structures to represent relationships of elements, a comprehensive way to repersent trees is critical. As there is no current convention for creating tree structures in Faust, I've developed a method using the existing series and parallel/list methods in Faust.

The series operator ` : ` is used to seperate parent and child elements. For example the tree

```
   A
   |
   B
```

is repersented by

`A : B` 

in faust. 

To denote a parent element with multiple child elements, simply use a list `(a1, a2, ... an)` of children connected to a single parent. For example the tree

```
   A
  / \
 B   C

```
is repersented by

`A : (B, C)`

Finally, for a tree with many levels, simply break the tree into subtrees following the above rules and connect the subtree as if it was an indivual node. For example the tree

```
      A
     / \
    B   C
   /   / \
  X   Y   Z
```

can be repersented by

```
B_sub = B : X; //B subtree
C_sub = C : (Y, Z); //C subtree
tree = A : (B_sub, C_sub); //full tree
```

or more simply, using parentheses: 

`A : ((B : X), (C : (Y, Z)))`


