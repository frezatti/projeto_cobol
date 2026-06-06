//HERC01XX JOB (PROG4),
//             'EXECUTA PROGBANC',
//             CLASS=A,
//             MSGCLASS=H,
//             REGION=8M,TIME=1440,
//             MSGLEVEL=(1,1),
//             NOTIFY=HERC01
//*-------------------------------------------------------------------*
//* STEP 1: SORT AND CONCATENATE BANK ACCOUNT FILES (BY AGENCY)       *
//*-------------------------------------------------------------------*
//SORTSTEP EXEC PGM=SORT
//SYSOUT   DD   SYSOUT=*
//SORTIN   DD   DSN=HERC01.CONTAS.TXT,DISP=SHR
//* DESAFIO EXTRA: CONCATENATING NEW ACCOUNT FILE BEFORE SORTING
//         DD   DSN=HERC01.CONTAS.NOVAS.TXT,DISP=SHR
//SORTOUT  DD   DSN=HERC01.CONTAS.ORDENADO,DISP=OLD
//SYSIN    DD   *
  SORT FIELDS=(39,4,CH,A)
/*
//*-------------------------------------------------------------------*
//* STEP 2: EXECUTE YOUR COBOL PROGRAM TO GENERATE REPORT             *
//*-------------------------------------------------------------------*
//STEP01   EXEC PGM=PROGBANC
//STEPLIB  DD   DSN=HERC01.PRIVLIB.LOAD,DISP=SHR
//CONTASRT DD   DSN=HERC01.CONTAS.ORDENADO,DISP=SHR
//SYSOUT   DD   SYSOUT=*
