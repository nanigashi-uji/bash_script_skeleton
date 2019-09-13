# bash_script_skeleton
Template of shell script without side effect for "source".

## Features

- This script can be called as a standalone script file or as a function loaded by `source`.
- Internal shell variables are defined with `local`, and `env` command is used to set the environmental variables for sub-commands.
- Sample of the internal function/alias definisions with back-up/restore procedure of the global function/alias with the same name, except for main function `func_skeleton`.
- Sample of the interrupt handlers with back-up/restore procedure of the global definition and calling the global interrupt handler after its procecdures. The sample code is one of the most popular case, temporaly files/directory removeing. 

## Usage

1. Rename `func_skeleton` (Two places) with proper name as new commands.
2. Update help messages in `echo_usage`.
3. Implement the treatment of command line arguments by `getopts`.
4. Implement commands itself, it starts after the temporaly file/directory definstions until before the last clean-up procedure.
5. Update `cleanup` functions, if necessary. (For example, adding the restore procedure if addtional sub-function/alias are defined.
6. Update signal handlers if necessary.
