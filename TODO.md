# TODO

## critical path

- [ ] Archive to shelf/ any depreciated parts
- [ ] Integrate motor mount to top of lid in assembly
- [ ] New probe pinch holder make bayonette style to fit into new probe holder
- [ ] integrate into assembly - new probe holder

- [ ] scope parameters for vendored / set hardware within their own scope and "include" in main assembly
- [ ] split into three subassemblies - vessel, head, and frame
  - vessel: glass jar
  - head: retaining plate (w/ tie points), closure (w/ flange), rotational drive system, I/O & instrumentation ports
  - frame: ribs, base plate, threaded rods, spacers, nuts
- [ ] Better parameterization of the bayonette connectors so that inputs map obviously to the geometry of the connectors, for example, not to some arbitrary dimension in the middle of the connectors major and minor diameters. This is largely a concern of: A) intuitiveness and B) making it actually feasible to integrate into an assembly or as a composite part

- [ ] stronger interface-based design surrounding the bayonette connectors
  - bayonette connector lib --> generic port --> specific port (e.g. probe holder, motor mount, etc.)
  - the "tube interface" should be literally just a generic port with the optional center bore appropriately set and wrapping the radius / diameter print out on the part

## nice to haves

- [ ] Add curve / inflection point to holes in bayonette connectors to grip tubes better
