.data
# ...

.text
.globl main

main:
  addi sp, sp, -4
  sw s0, 0(sp)
  la s0, _answer

  # ...


main_exit:
  /* Simulation End */
  lw s0, 0(sp)
  addi sp, sp, 4
  ret