'SERVER
_TITLE ("SERVER")
host = _OPENHOST("TCP/IP:300")
DIM SHARED users(1 TO 1000)
DIM SHARED usersName(1 TO 1000)
DIM SHARED numclients
client = _OPENCLIENT("TCP/IP:300:localhost")
hname$ = "Server Host"
DO: _LIMIT 100
    newclient = _OPENCONNECTION(host)

    IF newclient THEN

        numclients = numclients + 1
        users(numclients) = newclient
        GET #users(numclients), , name$

        ' SendMessage name$, name$ + " HAS JOINED", client
    END IF

	CheckConnections
	CheckMessages
    GetMessage client
    SendMessage hname$, mymessage$, client
LOOP

SUB CheckConnections
    for i = 1 to numclients
        if users(i) then
        	DO _LIMIT 10
        		PUT #users(i), , "Checking"
        		GET #users(i), , message$
        		if message$ <> "" then
        			exit do
        		else
	        		ping = ping + 0.1
	        		if ping >= 5 then
	        			users(i) = 0
	        			for p = i to numClients
	        				users(p) = users(p + 1) 'there may be other things that need to be changed than this, but i haven't gotten a ton of time to check out the code
	        				usersName(p) = usersName(p + 1)
	        			next
	        			numClients = numClients - 1
	        			exit do
	        		end if
        		end if
            LOOP
        end if
    next
END SUB

SUB CheckMessages
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
END SUB

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
    IF mymessage$ = "/list" THEN
        FOR p = 1 TO numusers
            PRINT usersNames(p)
        NEXT
    ELSE
        IF mymessage$ = "" THEN SYSTEM ' [Enter] with no message ends program
        part3$ = name$ + ": " + mymessage$
        PUT #client, , part3$
        mymessage$ = ""
    END IF
END IF
IF k$ = CHR$(27) THEN SYSTEM ' [Esc] key ends program
END SUB
