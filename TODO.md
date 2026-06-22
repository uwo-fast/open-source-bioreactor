# TODO

## critical path

- [ ] Better parameterization of the bayonet connectors so that inputs map obviously to the geometry of the connectors
  - for example, not to some arbitrary dimension in the middle of the connectors major and minor diameters
  - this is largely a concern of: A) intuitiveness and B) making it actually feasible to integrate into an assembly or as a composite part

- [ ] stronger interface-based design surrounding the bayonet connectors
  - bayonet connector lib --> generic port --> specific port (e.g. probe holder, motor mount, etc.)
  - the "tube interface" should be literally just a generic port with the optional center bore appropriately set and wrapping the radius / diameter print out on the part

## model completeness / enhancement

- [ ] finish modelling peri pumps and integrating with a motor then into the assembly using the peri pump motor mount that has been modified to take the registered parameters for the motor and pump
- [ ] replace as many of the "generic" parameter registrations as possible with specific ones for the actual hardware (i.e. mcmaster carr part numbers or best effort for other parts)

## nice to haves

- [ ] Add curve / inflection point to holes in bayonet connectors to grip tubes better
  - sehan's idea, currently they grip really tight already so this is just a thought for improving the design if we find the tubes are slipping out too easily in testing; or if we wanted to reduce the interference fit and make it easier to insert the tubes in the first place while keeping them from slipping out
- [ ] optional end styles (sensor gland) for atlas probes to match product more closely

## second hardware revision

- [ ] use a less expensive shaft for the impeller and try and get in 300mm instead of oversized 400mm thats being compensated by the parameteric printed motor mount
  - might not need to be linear motion surface rated and all that
- [ ] swap out the threaded rods with printed parts
