# TODO

## critical path

- [ ] stronger interface-based design surrounding the bayonet connectors ports
  - bayonet connector lib --> generic port --> specific port (e.g. probe holder, thermocouple, etc.)
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
- [ ] review and revise geometry composition method of bayonet connectors to make it computationally more efficient (slow in viewer at the moment with multiple on the lid)
