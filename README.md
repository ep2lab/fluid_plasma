FLUID PLASMA
============
 
The fluid_plasma package contains two classes:
- The species class models a simple plasma fluid species (can be ions or
electrons). It basically has mass, charge, and defines the thermodynamics of
the species.
- The plasma class stores one ion species and N electron species, and adds the
method to compute the sonic velocity in the plasma.

There are three thermodynamic models defined so far (20121026):
- cold
- isothermal
- polytropic

Testing
-------

Unit tests are found in the /test subdirectory. After adding the package to
your Matlab path, you can run all tests by executing 'runtests' from this 
subdirectory.

License
-------

Copyright (c) 2017 Mario Merino. All rights reserved
