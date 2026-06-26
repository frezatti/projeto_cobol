       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIPGM.
      *----------------------------------------------------------------*
      * IBM CICS reference version.
      * This version shows the official EXEC CICS style with DFHAID,
      * DFHRESP, READ UPDATE, REWRITE, RETURN TRANSID and COMMAREA.
      * The active runnable TK5/KICKS version is ../CLIPGM.cbl.
      *----------------------------------------------------------------*
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY DFHAID.
       COPY CLISET.

       01  WS-RESP              PIC S9(08) COMP VALUE ZERO.
       01  WS-RESP2             PIC S9(08) COMP VALUE ZERO.
       01  WS-REG-LEN           PIC S9(04) COMP VALUE 80.
       01  WS-COMMAREA-LEN      PIC S9(04) COMP VALUE 7.

       01  WS-IN-CODCLI         PIC X(06) VALUE SPACES.
       01  WS-IN-FONE           PIC X(15) VALUE SPACES.
       01  WS-IN-CIDADE         PIC X(20) VALUE SPACES.
       01  WS-MSG               PIC X(40) VALUE SPACES.

       01  WS-CODIGO-VALIDO     PIC X VALUE 'N'.
           88 CODIGO-OK         VALUE 'S'.
           88 CODIGO-ERRO       VALUE 'N'.

       01  WS-COMMAREA.
           05 CA-ESTADO         PIC X(01) VALUE 'I'.
           05 CA-CODCLI         PIC X(06) VALUE SPACES.

       01  WS-CLIENTE-REG.
           05 CLI-CODCLI        PIC X(06).
           05 CLI-NOME          PIC X(30).
           05 CLI-FONE          PIC X(15).
           05 CLI-CIDADE        PIC X(20).
           05 FILLER            PIC X(09).

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05 LK-ESTADO         PIC X(01).
           05 LK-CODCLI         PIC X(06).

       PROCEDURE DIVISION.

       0000-INICIO.
           MOVE LENGTH OF WS-COMMAREA TO WS-COMMAREA-LEN
           IF EIBCALEN = ZERO
              PERFORM 1000-TELA-INICIAL
           ELSE
              IF EIBCALEN >= WS-COMMAREA-LEN
                 MOVE DFHCOMMAREA TO WS-COMMAREA
              END-IF
              PERFORM 2000-RECEBER-TELA
              PERFORM 3000-TRATAR-TECLA
           END-IF
           EXEC CICS RETURN END-EXEC.

       1000-TELA-INICIAL.
           PERFORM 7000-LIMPAR-MAPA
           MOVE 'DIGITE O CODIGO E PRESSIONE PF5.' TO MSGO
           PERFORM 8000-ENVIAR-E-RETORNAR.

       2000-RECEBER-TELA.
           EXEC CICS
                RECEIVE MAP('CLIMAP') MAPSET('CLISET') INTO(CLIMAPI)
                RESP(WS-RESP)
           END-EXEC
           IF WS-RESP = DFHRESP(MAPFAIL)
              IF EIBAID = DFHPF3
                 EXEC CICS RETURN END-EXEC
              ELSE
                 PERFORM 7000-LIMPAR-MAPA
                 MOVE 'INFORME O CODIGO DO CLIENTE.' TO MSGO
                 PERFORM 8000-ENVIAR-E-RETORNAR
              END-IF
           END-IF
           MOVE CODCLII TO WS-IN-CODCLI
           MOVE FONEI   TO WS-IN-FONE
           MOVE CIDADEI TO WS-IN-CIDADE.

       3000-TRATAR-TECLA.
           EVALUATE EIBAID
              WHEN DFHPF3
                   EXEC CICS RETURN END-EXEC
              WHEN DFHPF5
                   PERFORM 3200-CONSULTAR
              WHEN DFHPF6
                   PERFORM 3300-SALVAR
              WHEN OTHER
                   PERFORM 7000-LIMPAR-MAPA
                   MOVE WS-IN-CODCLI TO CODCLIO
                   MOVE 'TECLA INVALIDA.' TO MSGO
                   PERFORM 8000-ENVIAR-E-RETORNAR
           END-EVALUATE.

       3200-CONSULTAR.
           PERFORM 5000-VALIDAR-CODIGO
           PERFORM 7000-LIMPAR-MAPA
           MOVE WS-IN-CODCLI TO CODCLIO
           IF CODIGO-ERRO
              MOVE WS-MSG TO MSGO
              PERFORM 8000-ENVIAR-E-RETORNAR
           END-IF
           EXEC CICS
                READ FILE('CLIENTES') INTO(WS-CLIENTE-REG)
                     LENGTH(WS-REG-LEN) RIDFLD(WS-IN-CODCLI)
                     RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           EVALUATE WS-RESP
              WHEN DFHRESP(NORMAL)
                   MOVE CLI-CODCLI TO CODCLIO
                   MOVE CLI-NOME   TO NOMEO
                   MOVE CLI-FONE   TO FONEO
                   MOVE CLI-CIDADE TO CIDADEO
                   MOVE 'CLIENTE ENCONTRADO.' TO MSGO
              WHEN DFHRESP(NOTFND)
                   MOVE 'CLIENTE NAO ENCONTRADO.' TO MSGO
              WHEN OTHER
                   MOVE 'ERRO AO CONSULTAR CLIENTE.' TO MSGO
           END-EVALUATE
           PERFORM 8000-ENVIAR-E-RETORNAR.

       3300-SALVAR.
           PERFORM 5000-VALIDAR-CODIGO
           PERFORM 7000-LIMPAR-MAPA
           MOVE WS-IN-CODCLI TO CODCLIO
           MOVE WS-IN-FONE TO FONEO
           MOVE WS-IN-CIDADE TO CIDADEO
           IF CODIGO-ERRO
              MOVE WS-MSG TO MSGO
              PERFORM 8000-ENVIAR-E-RETORNAR
           END-IF
           EXEC CICS
                READ FILE('CLIENTES') INTO(WS-CLIENTE-REG)
                     LENGTH(WS-REG-LEN) RIDFLD(WS-IN-CODCLI)
                     UPDATE RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           EVALUATE WS-RESP
              WHEN DFHRESP(NORMAL)
                   MOVE WS-IN-FONE TO CLI-FONE
                   MOVE WS-IN-CIDADE TO CLI-CIDADE
                   EXEC CICS
                        REWRITE FILE('CLIENTES') FROM(WS-CLIENTE-REG)
                                LENGTH(WS-REG-LEN)
                                RESP(WS-RESP) RESP2(WS-RESP2)
                   END-EXEC
                   IF WS-RESP = DFHRESP(NORMAL)
                      MOVE CLI-NOME TO NOMEO
                      MOVE CLI-FONE TO FONEO
                      MOVE CLI-CIDADE TO CIDADEO
                      MOVE 'ALTERACAO REALIZADA.' TO MSGO
                   ELSE
                      MOVE 'ERRO AO SALVAR ALTERACAO.' TO MSGO
                   END-IF
              WHEN DFHRESP(NOTFND)
                   MOVE 'CLIENTE NAO ENCONTRADO.' TO MSGO
              WHEN OTHER
                   MOVE 'ERRO AO LOCALIZAR CLIENTE.' TO MSGO
           END-EVALUATE
           PERFORM 8000-ENVIAR-E-RETORNAR.

       5000-VALIDAR-CODIGO.
           MOVE 'N' TO WS-CODIGO-VALIDO
           MOVE SPACES TO WS-MSG
           IF WS-IN-CODCLI = SPACES
              MOVE 'INFORME O CODIGO DO CLIENTE.' TO WS-MSG
              EXIT PARAGRAPH
           END-IF
           IF WS-IN-CODCLI IS NUMERIC
              MOVE 'S' TO WS-CODIGO-VALIDO
           ELSE
              MOVE 'CODIGO DEVE SER NUMERICO.' TO WS-MSG
           END-IF.

       7000-LIMPAR-MAPA.
           MOVE LOW-VALUES TO CLIMAPO
           MOVE SPACES TO CODCLIO NOMEO FONEO CIDADEO MSGO.

       8000-ENVIAR-E-RETORNAR.
           MOVE LENGTH OF WS-COMMAREA TO WS-COMMAREA-LEN
           EXEC CICS
                SEND MAP('CLIMAP') MAPSET('CLISET') FROM(CLIMAPO)
                     ERASE FREEKB RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           EXEC CICS
                RETURN TRANSID('CLIE') COMMAREA(WS-COMMAREA)
                       LENGTH(WS-COMMAREA-LEN)
           END-EXEC.
