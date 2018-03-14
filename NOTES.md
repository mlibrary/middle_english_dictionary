

## ENTRY children and min/max arities:

AUTHOR           0    1
COMMENT          0    1
E-EDITION        0    9 (children are ED and LINK)
INDEX            0   57
INDEXB           0   57
INDEXC           0    1
IPMEP            0    3
JOLLIFFE         0    2
MSLIST           1    1
NOTE             0    3 (may contain a STENCIL)
SEVERS           0   31
STENCILLIST      1    1
TITLE            1    1
WELLS            0    3


## MSLIST children and min/max arities:

MS     1    63

## STENCILLIST children and min/max arities:

MSGROUP  0  63
VARGROUP 0   1

## MSGROUP

STG   1   7

## MSGROUP/STG
EDITION   1    1
REF       0    1
STENCIL   1    1
USE       0    1

## MSGROUP/STG/STENCIL

STENCIL
   ABBR   1    1
   DATE   1    1
   WORK   1    1
     AUTHOR  0   1

