'SERVER
_TITLE ("SERVER")
host = _OPENHOST("TCP/IP:80")
DIM users(1 TO 1000)
client = _OPENCLIENT("TCP/IP:80:localhost")
name$ = "Server Host"
DO: _LIMIT 100
    newclient = _OPENCONNECTION(host)

    IF newclient THEN

        numclients = numclients + 1
        users(numclients) = newclient
        GET #users(numclients), , name$
        PRINT "Newcomer approaching!"


    END IF

    FOR p = 1 TO numclients
        IF users(p) THEN
            GET #users(p), , message$
            IF message$ <> "" THEN
                FOR i = 1 TO numclients
                    IF users(i) THEN

                        PUT #users(i), , message$
                    END IF
                NEXT i
            END IF
        END IF
    NEXT p

    GetMessage client
    SendMessage name$, mymessage$, client
LOOP
SUB GetMessage (client)
GET #client, , newmessage$
IF newmessage$ <> "" THEN
    VIEW PRINT 1 TO 23
    LOCATE 23, 1
    PRINT newmessage$
    VIEW PRINT 1 TO 24
END IF
END SUB

SUB SendMessage (name$, mymessage$, client)
k$ = INKEY$
IF LEN(k$) THEN
    IF k$ = CHR$(8) AND LEN(mymessage$) <> 0 THEN
        mymessage$ = LEFT$(mymessage$, LEN(mymessage$) - 1)
    ELSE
        IF LEN(k$) = 1 AND ASC(k$) >= 32 THEN mymessage$ = mymessage$ + k$
    END IF
END IF
LOCATE 24, 1: PRINT SPACE$(80); ' erase previous message displayed
LOCATE 24, 1: PRINT name$ + ": "; mymessage$;
IF k$ = CHR$(13) THEN ' [Enter] sends the message
    IF mymessage$ = "" THEN SYSTEM ' [Enter] with no message ends program
    part3$ = name$ + ": " + mymessage$
    PUT #client, , part3$
    mymessage$ = ""
END IF
IF k$ = CHR$(27) THEN SYSTEM ' [Esc] key ends program
END SUB
