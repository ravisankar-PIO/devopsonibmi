#!/QOpenSys/usr/bin/sh
# ------------------------------------------------------------------------- #
# Program       : copy.sh
# Author        : Ravisankar Pandian
# Company       : Programmers.io
# Date Written  : 09/05/2024
# Inspired from : https://github.com/barrettotte/RPGLE-Twilio/blob/master/build.sh
# ------------------------------------------------------------------------- #
# This program reads current folder from IFS and
# copies .rpgle, .sqlrpgle, .clle, .sql, .prtf and .dspf to respective _SRC FILES_ into the IBMi
# You need to set the CUR_LIB to your library name to which the sources need to be copied.
# If the entered library is not present, it will be created.
# Set the application name which will be set as the source text for all the members.
# Once all the sources are copied, it will compile the objects in correct order.
# ------------------------------------------------------------------------- #
# short="${long:0:2}" ; echo "${short}"

# -----------------------------------------------------------
# Use Present Working Directory.
# -----------------------------------------------------------
IFS_DIR="${1:-$(pwd)}"

# -----------------------------------------------------------
# Set the current library where the programs will be compiled.
# -----------------------------------------------------------
CUR_LIB="RAVI"

# -----------------------------------------------------------
# Set the source physical file names.
# -----------------------------------------------------------
DDS_SRC="QDDSSRC"
RPGLE_SRC="QRPGLESRC"
CL_SRC="QCLLESRC"
SQL_SRC="QSQLSRC"
TXT_SRC="QTXTSRC"
MOD_SRC="QMODSRC"
SRC_TXT="Sources file"


# Set application name
APPLICATION="DevOps on Git"


# -----------------------------------------------------------
# Execute the command by setting the library first
# -----------------------------------------------------------
exec_cmd(){
    echo $1
    output=$(qsh -c "liblist -a $CUR_LIB ; system \"$1\"")
    if [ -n "$2" ]; then
    echo -e "$1\n\n$output" > "$IFS_DIR/logs/$2.log"
    fi
}

# -----------------------------------------------------------
# Copy all the sources to the respective source files.
# -----------------------------------------------------------
copy_source(){
    # For every file in the current IFS directory
    for FILE in "$IFS_DIR"/*
        do
        # Get the name of the member alone.
        justname=$(basename "$FILE")
        member="${justname%.*}"
        # Get the source type.
        ext="${justname##*.}"

        # If Display file source...
        if [[ $ext == 'dspf' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$DDS_SRC
            SRC_TYP="DSPF"

        # If Physical File Source...
        elif [[ $ext == 'pf' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$DDS_SRC
            SRC_TYP="PF"

        # If Printer Files...
        elif [[ $ext == 'prtf' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$DDS_SRC
            SRC_TYP="PRTF"

        # If RPGLE source...
        elif [[ $ext == 'rpgle' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$RPGLE_SRC
            SRC_TYP="RPGLE"

        # If SQLRPGLE source...
        elif [[ $ext == 'sqlrpgle' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$RPGLE_SRC
            SRC_TYP="SQLRPGLE"

        # If CLLE Source...
        elif [[ $ext == 'clle' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$CL_SRC
            SRC_TYP="CLLE"

        # If SQL Source...
        elif [[ $ext == 'sql' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$SQL_SRC
            SRC_TYP="SQL"

        # If plain texts or copy books...
        elif [[ $ext == 'txt' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$TXT_SRC
            SRC_TYP="TXT"

        # If Shell scripts...
        elif [[ $ext == 'sh' ]]; then
            echo -e "\n=========== Copying $member ============="
            SRC_FILE=$TXT_SRC
            SRC_TYP="SH"
        fi

        exec_cmd "CHGATR OBJ('$FILE') ATR(*CCSID) VALUE(819)"
        exec_cmd "CPYFRMSTMF FROMSTMF('$FILE') TOMBR('/QSYS.lib/$CUR_LIB.lib/$SRC_FILE.file/$member.mbr') \
        MBROPT(*REPLACE)"
        exec_cmd "CHGPFM FILE($CUR_LIB/$SRC_FILE) MBR($member) SRCTYPE($SRC_TYP) TEXT('$APPLICATION')"

        done
}


# -----------------------------------------------------------
# Compile the sources
# -----------------------------------------------------------
compile_source(){

    # Compile the PF
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'pf' ]]; then
                echo -e "\n=========== Building PF - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}" 
                exec_cmd "CRTPF FILE($CUR_LIB/$member) SRCFILE($CUR_LIB/$DDS_SRC)" $member
            fi
        done
        
    # Compile the Display Files
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'dspf' ]]; then
                echo -e "\n=========== Building DSPF - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}"  
                exec_cmd "CRTDSPF FILE($CUR_LIB/$member) SRCFILE($CUR_LIB/$DDS_SRC)  \
                REPLACE(*YES)" $member 
            fi
        done

    # Compile the Printer Files
    for FILE in "$IFS_DIR"/*
    do
        ext="${FILE##*.}"
        if [[ $ext == 'prtf' ]]; then
            echo -e "\n=========== Building PRTF - $FILE ============="
            filename=$(basename "$FILE")
            member="${filename%.*}"  
            exec_cmd "CRTPRTF FILE($CUR_LIB/$member) SRCFILE($CUR_LIB/$DDS_SRC) \
            REPLACE(*YES)" $member 
        fi
    done

    # Compile SQL
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'sql' ]]; then
                echo -e "\n=========== Building SQL - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}"  
                exec_cmd "RUNSQLSTM SRCFILE($CUR_LIB/$SQL_SRC) SRCMBR($member) COMMIT(*NONE) \
                 MARGINS(145) DFTRDBCOL(HOMESOFT) DBGVIEW(*SOURCE)" $member  
            fi
        done

    # Compile RPGLE
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'rpgle' ]]; then
                echo -e "\n=========== Building RPGLE - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}"  
                # short="${member:0:2}" 
                # if [[ $short == 'ia']]; then  
                # else
                exec_cmd "CRTBNDRPG PGM($CUR_LIB/$member) DFTACTGRP(*NO) \
                DBGVIEW(*SOURCE) REPLACE(*YES)" $member 
                # fi
                 
            fi
        done

    # Compile SQLRPGLE
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'sqlrpgle' ]]; then
                echo -e "\n=========== Building SQLRPGLE - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}"  
                # short="${member:0:2}" 
                # if [[ $short == 'ia']]; then
                # else
                exec_cmd "CRTSQLRPGI OBJ($CUR_LIB/$member) SRCFILE($CUR_LIB/$RPGLE_SRC) \
                COMMIT(*NONE) DBGVIEW(*SOURCE) REPLACE(*YES)" $member   
                # fi
            fi
        done

    # Compile CLLE
    for FILE in "$IFS_DIR"/*
        do
            ext="${FILE##*.}"
            if [[ $ext == 'clle' ]]; then
                echo -e "\n=========== Building CLLE - $FILE ============="
                filename=$(basename "$FILE")
                member="${filename%.*}"  
                exec_cmd "CRTBNDCL PGM($CUR_LIB/$member) SRCFILE($CUR_LIB/$CL_SRC) \
                DFTACTGRP(*NO) ACTGRP(*CALLER) DBGVIEW(*SOURCE)" $member   
            fi
        done
}


# -----------------------------------------------------------
# Create the required source files
# -----------------------------------------------------------
create_source_files(){
    system "CRTLIB LIB($CUR_LIB) TYPE(*TEST) TEXT('$CUR_LIB library')"
    system "CRTSRCPF FILE($CUR_LIB/$DDS_SRC) RCDLEN(140) TEXT('$DDS_SRC $SRC_TXT')"
    system "CRTSRCPF FILE($CUR_LIB/$RPGLE_SRC) RCDLEN(140) TEXT('$RPGLE_SRC $SRC_TXT')"
    system "CRTSRCPF FILE($CUR_LIB/$CL_SRC) RCDLEN(140) TEXT('$CL_SRC $SRC_TXT')"
    system "CRTSRCPF FILE($CUR_LIB/$SQL_SRC) RCDLEN(140) TEXT('$SQL_SRC $SRC_TXT')"
    system "CRTSRCPF FILE($CUR_LIB/$TXT_SRC) RCDLEN(140) TEXT('$TXT_SRC $SRC_TXT')"
    system "CHGPDMDFT USER($CUR_LIB) CRTBCH(*NO) EXITENT(*NO) CHGTYPTXT(*NO)"
    PATH=/QOpenSys/pkgs/bin:$PATH
}


# ----------------------------------------------------------- #
# ----------------------------------------------------------- #
#                                                             #  
#                 Start of the main logic                     #  
#                                                             #  
# ----------------------------------------------------------- #
# ----------------------------------------------------------- #



echo -e "|=== Starting to copy the programs for $APPLICATION ===|"
mkdir -p logs


# STEP 1: CREATE THE TARGET LIBRARY AND SOURCE FILE ----------------- 
    create_source_files

# STEP 2: COPY THE SOURCES FROM IFS INTO THE TARGET LIBRARY --------
    copy_source
    
# STEP 3: COMPILE THE SOURCES INTO THE TARGET LIBRARY --------------     
    compile_source

# STEP 4: REMOVE THE SOURCES FROM IFS
    #shopt -s extglob
    #rm -r -- !(compile.sh)

echo -e '|============================================================|'
echo -e '| Program build completed, please check log files if you want|'
echo -e "|               $IFS_DIR/logs                                |"
echo -e '|============================================================|'
