#!/bin/bash
#File: create_dir_structure_for_makefile.sh
#Project: scripts
#Created Date: Wednesday, March 4th 2020, 8:45:54
#Author: Christian
#-----
#Last Modified: Monday, March 9th 2020, 13:31:56
#Modified By: Christian
#-----
#
#Change log:
#Date By Comments
#---------- --- ----------------------------------------------------------

# This script, called with the command "./create_directory_structure_for_makefile.sh /destination/to/your/c/or/c++/project/folder/" ,
# where the destination to your project is ultimately up to you to name, will create the folder structure and required files for coding
# and compiling C and C++ code projects for both Linux (host) and Raspberry PI (target) compiled on a Linux system.
#
# NOTE; To be able to compile, one must've installed the following packages on one's Linux system beforehand:
# make, gcc, g++
# All three can be installed with following command in a Linux terminal (as of the writing of this documentation):
# "sudo apt install make gcc g++"
#
#
# ***The folder structure is as follows***
# The script will create five folders named bin, deps, obj, include, src
#
# ***Explanation of each folders contents***
# "bin"-folder holds, in sub directories "target" or "host", the compiled program called prog.exe
# deps holds, in sub directories "target" or "host", dependency files after compiling with make
# obj holds, in sub directories "target" or "host", object files after compiling with make
# include is where you put your header files, either .hpp for C++ projects or .h for C projects
# src is where you put your source files, either .cpp for C++ projects or .C for C projects
#
# The script also creates a Makefile telling the compiler how to create dependencies and how to link files into a compiled program.
# After finishing your project, you're able to compile the files (given they are placed in the specified folders above) into a program
# with different commands when your present working directory is the same as the destination given when calling this script.
#
# ***Explanation of each command***
# "make ARCH=host" compiles the program for a Linux host system
# "make ARCH=target" compiles for the arm architecture of the Raspberry PI
# "make ARCH=host clean" deletes all compiled files for the host build (only dependencies, objects and the program itself, *NOT* your source and header files)
# Same as above line goes for ARCH=target
# "make ARCH=host run" compiles and runs the program straight after clearing the terminal window (This command cannot be run with ARCH=target

# as running the program would require the arm architecture of the Raspberry PI)
if [ "$1" = "" ]; then
echo "Missing parameter. Please provide directory destination for folder structure. eg. '/home/user/project_name/' ."
else
mkdir -p $1bin $1deps $1include $1obj $1src
if [ -d $1 ]; then
echo "SRC_DIR ?= src" > $1Makefile
echo "INC_DIR ?= include" >> $1Makefile
echo >> $1Makefile
echo "SOURCES := \$(notdir \$(shell find \$(SRC_DIR) -name *.cpp -or -name *.c))" >> $1Makefile
echo "OBJECTS = \$(addprefix \$(OBJ_DIR), \$(SOURCES:\$(suffix \$(firstword \$(SOURCES)))=.o))" >> $1Makefile
echo "DEPS = \$(addprefix \$(DEP_DIR), \$(SOURCES:\$(suffix \$(firstword \$(SOURCES)))=.d))" >> $1Makefile
echo >> $1Makefile
echo "EXE = \$(BIN_DIR)prog.exe" >> $1Makefile
echo "CXXFLAGS = -Wall -Wextra -Iinclude -ggdb -pthread # Compiler flags" >> $1Makefile
echo >> $1Makefile
echo "# Making for host (Linux)" >> $1Makefile
echo "# > make ARCH=host" >> $1Makefile
echo "ifeq (\${ARCH},host)" >> $1Makefile
echo "ifeq (\$(suffix \$(firstword \$(SOURCES))),.cpp) # If src files = .cpp" >> $1Makefile
echo "COMPILER = g++" >> $1Makefile
echo "OBJ_DIR = obj/host/" >> $1Makefile
echo "DEP_DIR = deps/host/" >> $1Makefile
echo "BIN_DIR = bin/host/" >> $1Makefile
echo "STDFLAG = -std=c++17 # C++ std compiler flag for C++ 17" >> $1Makefile
echo "\$(shell mkdir -p \$(OBJ_DIR) \$(DEP_DIR) \$(BIN_DIR))" >> $1Makefile
echo "endif" >> $1Makefile
echo "ifeq (\$(suffix \$(firstword \$(SOURCES))),.c) # If src files = .c" >> $1Makefile
echo "COMPILER = gcc" >> $1Makefile
echo "OBJ_DIR = obj/host/" >> $1Makefile
echo "DEP_DIR = deps/host/" >> $1Makefile
echo "BIN_DIR = bin/host/" >> $1Makefile
echo "STDFLAG = -std=c11 # C std compiler flag for C 17" >> $1Makefile
echo "\$(shell mkdir -p \$(OBJ_DIR) \$(DEP_DIR) \$(BIN_DIR))" >> $1Makefile
echo "endif" >> $1Makefile
echo "endif" >> $1Makefile
echo >> $1Makefile
echo "# Making for target (Raspberry PI)" >> $1Makefile
echo "# > make ARCH=target" >> $1Makefile
echo "ifeq (\${ARCH},target)" >> $1Makefile
echo "ifeq (\$(suffix \$(firstword \$(SOURCES))),.cpp) # If src files = .cpp" >> $1Makefile
echo "COMPILER = arm-linux-gnueabihf-g++" >> $1Makefile
echo "OBJ_DIR = obj/target/" >> $1Makefile
echo "DEP_DIR = deps/target/" >> $1Makefile
echo "BIN_DIR = bin/target/" >> $1Makefile
echo "STDFLAG = -std=c++17 # C++ std compiler flag for C++ 17" >> $1Makefile
echo "\$(shell mkdir -p \$(OBJ_DIR) \$(DEP_DIR) \$(BIN_DIR))" >> $1Makefile
echo "endif" >> $1Makefile
echo "ifeq (\$(suffix \$(firstword \$(SOURCES))),.c) # If src files = .c" >> $1Makefile
echo "COMPILER = arm-linux-gnueabihf-gcc" >> $1Makefile
echo "OBJ_DIR = obj/target/" >> $1Makefile
echo "DEP_DIR = deps/target/" >> $1Makefile
echo "BIN_DIR = bin/target/" >> $1Makefile
echo "STDFLAG = -std=c11" >> $1Makefile
echo "\$(shell mkdir -p \$(OBJ_DIR) \$(DEP_DIR) \$(BIN_DIR))" >> $1Makefile
echo "endif" >> $1Makefile
echo "endif" >> $1Makefile
echo >> $1Makefile
echo "\$(EXE): \$(DEPS) \$(OBJECTS) # << Check new dependency" >> $1Makefile
echo -e "\t\$(COMPILER) \$(CXXFLAGS) \$(STDFLAG) -o \$@ \$(OBJECTS)" >> $1Makefile
echo >> $1Makefile
echo "# Rule that describes how a .d (dependency) file is created from a .cpp file" >> $1Makefile
echo "\${DEP_DIR}%.d: \$(SRC_DIR)/%\$(suffix \$(firstword \$(SOURCES)))" >> $1Makefile
echo -e "\t\$(COMPILER) -MT\$(@:.d=.o) -MM \$(CXXFLAGS) \$(STDFLAG) \$^ >> \$@" >> $1Makefile
echo -e "\t\$(COMPILER) -MT\$@ -MM \$(CXXFLAGS) \$(STDFLAG) \$^ > \$@" >> $1Makefile
echo >> $1Makefile
echo "# Rule that describes how an .o (object) file is created from a .cpp file" >> $1Makefile
echo "\${OBJ_DIR}%.o: \$(SRC_DIR)/%\$(suffix \$(firstword \$(SOURCES)))" >> $1Makefile
echo -e "\t\$(COMPILER) \$(CXXFLAGS) \$(STDFLAG) -I\$(INC_DIR) -c \$< -o \$@" >> $1Makefile
echo >> $1Makefile
echo "ifneq (\$(filter-out clean format tidy,\$(MAKECMDGOALS)),)" >> $1Makefile
echo "-include \$(DEPS)" >> $1Makefile
echo "endif" >> $1Makefile
echo >> $1Makefile
echo "all: \$(EXE)" >> $1Makefile
echo >> $1Makefile
echo "run: all" >> $1Makefile
echo -e "\tclear" >> $1Makefile
echo -e "\t@./\$(EXE)" >> $1Makefile
echo >> $1Makefile
echo "clean:" >> $1Makefile
echo -e "\t@rm -rf \$(OBJ_DIR) \$(DEP_DIR) \$(BIN_DIR)" >> $1Makefile
echo >> $1Makefile
echo ".PHONY: all run clean" >> $1Makefile

# -------------------------------------------------------------------------------- #
echo "#!/bin/bash" > $1scp_to_rpi.sh
echo "# Script for secure copying files from host to target (Raspberry PI)" >> $1scp_to_rpi.sh
echo "# One parameter:" >> $1scp_to_rpi.sh
echo "# 1) The IP-address of the target Raspberry PI." >> $1scp_to_rpi.sh
echo "#" >> $1scp_to_rpi.sh
echo "# Example of calling the script in the terminal:" >> $1scp_to_rpi.sh
echo "# \"./scp_to_pi.sh 10.9.8.2\"" >> $1scp_to_rpi.sh
echo "# This will copy prog.exe from the host machine to the '/home/pi/Downloads/' directory on the Raspberry PI." >> $1scp_to_rpi.sh
echo "if [ \"\$1\" = \"\" ]; then" >> $1scp_to_rpi.sh
echo -e "\techo \"Missing IP-address for target.\"" >> $1scp_to_rpi.sh
echo -e "\techo \">>> Example of correct parameter '10.9.8.2' <<<\"" >> $1scp_to_rpi.sh
echo "else" >> $1scp_to_rpi.sh
echo -e "\techo \"Copying file 'prog.exe' to destination 'home/pi/Downloads/' on Raspberry PI\"" >> $1scp_to_rpi.sh
echo -e "\tscp bin/target/prog.exe pi@\$1:Downloads/" >> $1scp_to_rpi.sh
echo "fi" >> $1scp_to_rpi.sh
chmod +x $1scp_to_rpi.sh
echo "Directory and file structure successfully created in filepath '$1'"
else
echo "Faulty parameter - is not a directory. Please provide directory destination for folder structure. eg. '/home/user/project_name/' ."
fi
fi
