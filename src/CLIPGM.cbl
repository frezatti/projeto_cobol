       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIPGM.
       AUTHOR. ADRIEL FREZATTI.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WKR-VARIABLES.
           05  WKR-CODCLI      PIC X(06) VALUE SPACES.
           05  WKR-NOME        PIC X(30) VALUE SPACES.
           05  WKR-FONE        PIC X(15) VALUE SPACES.
           05  WKR-CIDADE      PIC X(20) VALUE SPACES.
           05  WKR-MSG         PIC X(40) VALUE SPACES.

           05  WKR-RESP        PIC S9(4) COMP VALUE +0.
           05  WKR-REG-LEN     PIC S9(4) COMP VALUE +80.
           05  WKR-KEY-LEN     PIC S9(4) COMP VALUE +6.

           05  WKR-PF3         PIC X VALUE X'F3'.
           05  WKR-PF5         PIC X VALUE X'F5'.
           05  WKR-PF6         PIC X VALUE X'F6'.

           05  WKR-NORMAL      PIC S9(4) COMP VALUE +0.
           05  WKR-NOTFND      PIC S9(4) COMP VALUE +13.

       01  WKR-CLIENTE-REG.
           05  CLI-CODCLI      PIC X(06).
           05  CLI-NOME        PIC X(30).
           05  CLI-FONE        PIC X(15).
           05  CLI-CIDADE      PIC X(20).
           05  FILLER          PIC X(09).

           COPY CLISET.

       PROCEDURE DIVISION.

       MAIN-PROCESS.
           MOVE SPACES TO WKR-CODCLI.
           MOVE SPACES TO WKR-NOME.
           MOVE SPACES TO WKR-FONE.
           MOVE SPACES TO WKR-CIDADE.
           MOVE 'V3 DIGITE O CODIGO E PF5.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       RECEIVE-SCREEN.
           EXEC KICKS
                RECEIVE MAP('CLIMAP')
                        MAPSET('CLISET')
                        INTO(CLIMAPI)
                        NOHANDLE
           END-EXEC.

           IF EIBAID = WKR-PF3
              GO TO EXIT-PROGRAM.

           IF EIBAID = WKR-PF5
              GO TO SEARCH-PROCESS.

           IF EIBAID = WKR-PF6
              GO TO UPDATE-PROCESS.

           MOVE 'USE PF3, PF5 OU PF6.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       SEARCH-PROCESS.
           MOVE CODCLII TO WKR-CODCLI.

           PERFORM VALIDATE-CODE.
           IF WKR-MSG = SPACES
              GO TO SEARCH-READ.

           GO TO DISPLAY-SCREEN.

       SEARCH-READ.
           MOVE SPACES TO WKR-CLIENTE-REG.
           MOVE WKR-NORMAL TO WKR-RESP.

           EXEC KICKS
                READ DATASET('CLIENTES')
                     INTO(WKR-CLIENTE-REG)
                     LENGTH(WKR-REG-LEN)
                     RIDFLD(WKR-CODCLI)
                     KEYLENGTH(WKR-KEY-LEN)
                     RESP(WKR-RESP)
                     NOHANDLE
           END-EXEC.

           IF WKR-RESP = WKR-NORMAL
              GO TO CLIENT-FOUND.

           IF WKR-RESP = WKR-NOTFND
              GO TO CLIENT-NOT-FOUND.

           MOVE SPACES TO WKR-NOME.
           MOVE SPACES TO WKR-FONE.
           MOVE SPACES TO WKR-CIDADE.
           MOVE 'ERRO AO CONSULTAR CLIENTE.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       UPDATE-PROCESS.
           MOVE CODCLII TO WKR-CODCLI.
           MOVE FONEI   TO WKR-FONE.
           MOVE CIDADEI TO WKR-CIDADE.

           PERFORM VALIDATE-CODE.
           IF WKR-MSG = SPACES
              GO TO UPDATE-READ.

           GO TO DISPLAY-SCREEN.

       UPDATE-READ.
           MOVE SPACES TO WKR-CLIENTE-REG.
           MOVE WKR-NORMAL TO WKR-RESP.

           EXEC KICKS
                READ DATASET('CLIENTES')
                     INTO(WKR-CLIENTE-REG)
                     LENGTH(WKR-REG-LEN)
                     RIDFLD(WKR-CODCLI)
                     KEYLENGTH(WKR-KEY-LEN)
                     UPDATE
                     RESP(WKR-RESP)
                     NOHANDLE
           END-EXEC.

           IF WKR-RESP = WKR-NORMAL
              GO TO COMMIT-UPDATE.

           IF WKR-RESP = WKR-NOTFND
              GO TO CLIENT-NOT-FOUND.

           MOVE 'ERRO AO LOCALIZAR CLIENTE.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       COMMIT-UPDATE.
           MOVE WKR-FONE   TO CLI-FONE.
           MOVE WKR-CIDADE TO CLI-CIDADE.
           MOVE WKR-NORMAL TO WKR-RESP.

           EXEC KICKS
                REWRITE DATASET('CLIENTES')
                        FROM(WKR-CLIENTE-REG)
                        LENGTH(WKR-REG-LEN)
                        RESP(WKR-RESP)
                        NOHANDLE
           END-EXEC.

           IF WKR-RESP = WKR-NORMAL
              GO TO UPDATE-SUCCESS.

           MOVE 'ERRO AO SALVAR ALTERACAO.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       VALIDATE-CODE.
           MOVE SPACES TO WKR-MSG.

           IF WKR-CODCLI = SPACES
              GO TO CODE-BLANK.

           IF WKR-CODCLI IS NUMERIC
              GO TO VALIDATE-CODE-END.

           MOVE 'CODIGO DEVE SER NUMERICO.' TO WKR-MSG.
           GO TO VALIDATE-CODE-END.

       CODE-BLANK.
           MOVE 'INFORME O CODIGO DO CLIENTE.' TO WKR-MSG.
           GO TO VALIDATE-CODE-END.

       VALIDATE-CODE-END.
           EXIT.

       CLIENT-FOUND.
           MOVE CLI-CODCLI TO WKR-CODCLI.
           MOVE CLI-NOME   TO WKR-NOME.
           MOVE CLI-FONE   TO WKR-FONE.
           MOVE CLI-CIDADE TO WKR-CIDADE.
           MOVE 'CLIENTE ENCONTRADO.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       CLIENT-NOT-FOUND.
           MOVE SPACES TO WKR-NOME.
           MOVE SPACES TO WKR-FONE.
           MOVE SPACES TO WKR-CIDADE.
           MOVE 'CLIENTE NAO ENCONTRADO.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       UPDATE-SUCCESS.
           MOVE CLI-CODCLI TO WKR-CODCLI.
           MOVE CLI-NOME   TO WKR-NOME.
           MOVE CLI-FONE   TO WKR-FONE.
           MOVE CLI-CIDADE TO WKR-CIDADE.
           MOVE 'ALTERACAO REALIZADA.' TO WKR-MSG.
           GO TO DISPLAY-SCREEN.

       DISPLAY-SCREEN.
           MOVE LOW-VALUES TO CLIMAPO.

           MOVE 6          TO CODCLIL.
           MOVE WKR-CODCLI TO CODCLIO.

           MOVE 30         TO NOMEL.
           MOVE WKR-NOME   TO NOMEO.

           MOVE 15         TO FONEL.
           MOVE WKR-FONE   TO FONEO.

           MOVE 20         TO CIDADEL.
           MOVE WKR-CIDADE TO CIDADEO.

           MOVE 40         TO MSGL.
           MOVE WKR-MSG    TO MSGO.

           EXEC KICKS
                SEND MAP('CLIMAP')
                     MAPSET('CLISET')
                     FROM(CLIMAPO)
                     ERASE
                     FREEKB
           END-EXEC.

           GO TO RECEIVE-SCREEN.

       EXIT-PROGRAM.
           EXEC KICKS
                RETURN
           END-EXEC.
