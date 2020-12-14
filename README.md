# faust-wdf-library

This library is intended for use for creating Wave Digital Filter (WDF) based models of audio circuitry for real-time audio processing within the Faust programming language. The goal is to provide a framework to create real-time virtual-analog audio effects and synthesizers using WDF models without the use of C++. Furthermore, we seek to provide access to the technique of WDF modeling to those without extensive knowledge of advanced digital signal processing techniques. Finally, we hope to provide a library which can integrate with all aspects of Faust, thus creating a platform for virtual circuit bending. 

The library itself is written in Faust to maintain portability. 

This library is heavily based on Kurt Werner's Dissertation, "Virtual Analog Modeling of Audio Circuitry Using Wave Digital Filters." I have tried to maintain consistent notation between the adaptors appearing within thesis and my adaptor code. The majority of the adaptors found in chapter 1 and chapter 3 are currently supported. 

For inquires about use of this library in a commercial product, please contact dirk [dot] roosenburg [dot] 30 [at] gmail [dot] com

## Using this Library

Use of this library expects some level of familiarity with WDF techniques, especially simplification and decomposition of electronic circuits into WDF connection trees. I plan to create video to cover both these techniques and use of the library. 

### Quick Start

to get a quick overview of the library, start with the `secondOrderFilters.dsp` code found in `examples`. If using the [online Faust IDE](https://faustide.grame.fr/) just download and drag in the sample code. 

### A Simple RC Filter Model

Creating a model using this library consists fo three steps. First, declare a set of components. Second, model the relationship between them using a tree. Finally, build the tree using the libraries build functions.  

First, a set of components is declared using adaptors from the library.  This list of components is created based on analysis of the circuit using WDF techniques, though generally each circuit element (resistor, capacitor, diode, etc.) can be expected to appear within the component set. For example, first order RC lowpass filter would require an unadapted voltage source, a 47k resistor, and a 10nF capacitor which outputs the voltage across itself. These can be declared with: 

```
vs1(i) = wd.u_voltage(i, no.noise);
r1(i) = wd.resistor(i, 47*10^3);
c1(i) = wd.capacitor_output(i, 10*10^-9);
```

Note that the first argument, i, is left un-parametrized. Components must be declared in this form, as the build algorithm expects to receive adaptors which have exactly one parameter. 

Also note that we have chosen to declare a white noise function as the input to our voltage source. We could potentially declare this as a direct input to our model, but to do so is more complicated process which cannot be covered within this tutorial. For information on how to do this see Declaring Model Parameters as Inputs or see various implementations in `examples`.


Second, the declared components and interconnection/structural adaptors (i.e. series, parallel, etc) are arranged into the connection tree which is produced from performing WDF analysis on the modeled circuit. For example, to produce our first order RC lowpass circuit model, the following tree is declared: 

`tree_lowpass = vs1(i) : wd.series : (r1, c1)`

For more information on how to represent trees in Faust, see Trees in Faust. 

Finally, the tree is built using the the `buildtree` function. To build and compute our first order RC lowpass circuit model, we use

`process = wd.buildtree(tree_lowpass);`

More information about build functions, see Build Functions. 

### Building a Model

After creating a connection tree which consists of WDF adaptors, the connection tree must be passed to a build function in order to build the model.

##### Automatic model building 

`buildtree(connection_tree)`

The simplest build function for use with basic models. This automatically implements `buildup`, `builddown`, and `buildout` to create a working model. However, it gives minimum control to the user and cannot currently be used on trees which have parameters declared as inputs.

##### Manual model building

Wave Digital Filters are an explicit state-space model, meaning they use a previous system state in order to calculate the current output. This is achieved in Faust by using a single global feedback operator. The models feed-forward terms are generated using `builddown` and the models feedback terms are generated using `buildup`. Thus, the most common model implementation (the method used by `buildtree`) is

`builddown(connection_tree)~buildup(connection_tree) : buildout(connection_tree)`.

Since the `~` operator in Faust will leave feedback terms hanging as outputs, `buildout` is a function provided for convenience. It automatically truncates the hanging outputs by identifying leaf components which have an intended output and generating an output matrix.

Building the model manually allows for greater user control and is often very helpful in testing. Also provided for testing are the `getres` and `parres` functions, which can be used to determine the upward-facing port resistance of an element. 

### Declaring Model Parameters as Inputs

When possible, parameters of components should be declared explicitly, meaning they are dependent on a function with no inputs. This might be something as simple as integer(declaring a static component), a function dependent on a UI input (declaring a component with variable value), or even a time-dependent function like an oscillator (declaring an audio input or circuit bending). 

However, it is often necessary to declare parameters as input. To achieve this there are two possible methods. The first and recommended option is to create a separate model function and declare parameters which will later be implemented as inputs. This allows inputs to be explicitly declared as component parameters. For example, one might use

```
model(in1) = buildtree(tree)
with{
   ...
   vin(i) = wd.u_voltage(i, in1);
   ...

   tree = vin : ...; 
};
```

In order to simulate an audio input to the circuit. 

Note that the tree and components must be declared inside a `with{...}` statement, or the model's parameters will not be accessible. 

##### Depreciated Input Method (Not Recommended)

It is also possible to declare inputs using the signal operator, `_`. For example, one might use

`vin(i) = wd.u_voltage(i, _);`

in order to simulate an audio input to the circuit.

However, since build functions do not have access to individual component parameter details, the task of declaring inputs using this method can quickly become complex and **is not recommended**. 

Only the root and bottom-most / left-most leaf element can accept a parameter input this way. 

Additionally, manual routing must be performed within the feedforward term as the function input/output mismatch will cause errors in the model. 


### Trees in Faust

Since WDF models use connection trees to represent relationships of elements, a comprehensive way to represent trees is critical. As there is no current convention for creating trees in Faust, I've developed a method using the existing series and parallel/list methods in Faust.

The series operator ` : ` is used to separate parent and child elements. For example the tree

```
   A
   |
   B
```

is represented by

`A : B` 

in faust. 

To denote a parent element with multiple child elements, simply use a list `(a1, a2, ... an)` of children connected to a single parent. For example the tree

```
   A
  / \
 B   C

```
is represented by

`A : (B, C)`

Finally, for a tree with many levels, simply break the tree into subtrees following the above rules and connect the subtree as if it was an individual node. For example the tree

```
      A
     / \
    B   C
   /   / \
  X   Y   Z
```

can be represented by

```
B_sub = B : X; //B subtree
C_sub = C : (Y, Z); //C subtree
tree = A : (B_sub, C_sub); //full tree
```

or more simply, using parentheses: 

`A : ((B : X), (C : (Y, Z)))`

### How Adaptors are Structured

In wave digital filters, adaptors can be described by the form 

`b = Sa`

where `b` is a vector of output waves `b = (b0, b1, b2, ... bn)`, `a` is a vector of input waves`a = (a0, a1, a2, ... an)`, and `S` is an n x n scattering matrix. `S` is dependent on `R`, a list of port resistances `(R0, R1, R2, ... Rn)`. 

The output wave vector `b` can be divided into downward-going and upward-going waves (downward-going waves travel down the connection tree, upward-going waves travel up). For adapted adaptors, with the zeroth port being  the upward-facing port, the downward-going wave vector is `(b1, b2, ... bn)` and the upward-going wave vector is `(b0)`. For unadapted adaptors, there are no upward-going waves, so the downward-going wave vector is simply `b = (b0, b1, b2, ... bn)`. 

In order for adaptors to be interpretable by the compiler, they must be structured in a specific way. 
Each adaptor is divided into three cases by their first parameter. This parameter, while accessible by the user, should only be set by the compiler/builder.

All other parameters are value declarations (for components), inputs (for voltage or current ins), or parameter controls (for potentiometers/variable capacitors/variable inductors)

##### first case - downward going waves

`(0, params) => downward-going(R1, ... Rn, a0, a1, ... an)` 
outputs : `(b1, b2, ... bn)`

   this function takes any number of port resistances, the downward going wave, and any number of upward going waves as inputs. 
   
   These values/waves are used to calculate the downward going waves coming from this adaptor

##### second case 

`(1, params) =>  upward-going(R1, ... Rn, a1, ... an)`
outputs : `(b0)`

   this function takes any number of port resistances and any number of upward going waves as inputs

   these values/waves are used to calculate the upward going wave coming from this adaptor

##### third case  

`(2, params) => port-resistance(R1, ... Rn)` 
outputs:  `(R0)`

   this function takes any number of port resistances as inputs

   these values are used to calculate the upward going port resistance of the element


##### Unadapted Adaptors

Unadapted adaptor's names will always begin "u_"
An unadapted adaptor MUST be used as the root of the WDF connection tree.
Unadapted adaptors can ONLY be used as a root of the WDF connection tree. 
While unadapted adaptors contain all three cases, the second and third are purely structural. 
Only the first case should contain computational information. 

### How the Build Functions Work

Expect this section to be added soon! It's currently the subject of a paper which I hope to publish soon. The explanation involves the creation of a "meta-language" in Faust and is not within the scope of an introduction. 

## Acknowledgements

Many thanks to Kurt Werner for helping me to understand wave digital filter models. Without his publications and consultations, the library would not exist. 
Thanks also to my advisors, Rob Owen and Eli Stine whose input was critical to the development of the library.
Finally, thanks to Romain Michon, Stephane Letz, and the Faust slack for contributing to testing, development, and inspiration when creating the library. 

