# wrapper

Wrapper is a simple command-line utility that generates a s-expression file for Reggae tool.

It reads a VHDL file generated by VivadoHLS and deduce a set of interface registers to interact with the generated IP.

## Install :
- No Ruby gem provided today
- Simply clone the projet and add /bin/wrapper to your PATH
- you also need to install gem Vertigo : gem install vertigo_vhdl
- this Tool is useless without Reggae : gem install reggae_eda

## Usage :
wrapper -d 32 -a 8 top_level.vhd

## Contact :
jean-christophe.le_lann at ensta-bretagne.fr
