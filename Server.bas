'SERVER
_TITLE ("SERVER")
host = _OPENHOST("TCP/IP:300")
DIM SHARED users(1 TO 1000)
DIM SHARED usersName$(1 TO 1000)
DIM SHARED usersFails(1 TO 1000)
DIM SHARED numclients
client = _OPENCLIENT("TCP/IP:300:localhost")
hname$ = "Server Host"
DIM SHARED version$
version$ = "2015.10.04.Dev"

DO: _LIMIT 100
    newclient = _OPENCONNECTION(host)

    IF newclient THEN

        numclients = numclients + 1
        users(numclients) = newclient
        GET #users(numclients), , name$
        usersName$(numclients) = name$

        ' SendMessage name$, name$ + " HAS JOINED", client
    END IF

    CheckMessages
    GetMessage client
    SendMessage hname$, mymessage$, client
LOOP

'MESSAGE TYPES
'1 = Regular message
'2 = Command
'3 = Connection Check

SUB CheckMessages
FOR p = 1 TO numclients
    IF users(p) THEN
        GET #users(p), , message$

        SELECT CASE LEFT$(message$, 1) 'checks what message type it is

            CASE "1": 'regular message
                usersFails(p) = 0
                FOR i = 1 TO numclients
                    IF users(i) THEN
                        message$ = RIGHT$(message$, LEN(message$) - 1) 'only prints what's after the message type indicator
                        PUT #users(i), , message$
                    END IF
                NEXT i

            CASE "2": 'command
                usersFails(p) = 0
                SELECT CASE RIGHT$(message$, LEN(message$) - 1) 'checks what command is being ran
                    CASE "list": 'lists all online users and sends to the client that requested it
                        FOR i = 1 TO numclients
                            servermessage$ = servermessage$ + usersName$(i)
                        NEXT
                        PUT #client, , servermessage$
                        servermessage$ = ""
                END SELECT
            CASE "3": 'connection confirmation
                usersFails(p) = 0
            CASE "": 'no message recieved on attempt
                usersFails(p) = usersFails(p) + 1
                IF usersFails(p) = 500 then
                    users(p) = 0
                    usersName$(p) = 0
                    usersFails(p) = 0
                    CLOSE #users(p)
                    for i = p to numclients
                        users(p) = users(p + 1)
                        usersName$(p) = usersName$(p + 1)
                        usersFails(p) = usersFails(p + 1)
                        
                    next i
                    numclients = numclients - 1
                end if
            
        END SELECT
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
    IF LEFT$(mymessage$, 1) = "/" THEN 'checks if user is running a command
        mymessage$ = "2" + RIGHT$(mymessage$, LEN(mymessage$) - 1) ' replaces "/" with "2" to show message type
        PUT #client, , mymessage$
    ELSE
        mymessage$ = "1" + mymessage$
        PUT #client, , mymessage$
        mymessage$ = ""
    END IF
ELSE
    confirmation$ = "3"
    put #client, , confirmation$
END IF
IF k$ = CHR$(27) THEN SYSTEM ' [Esc] key ends program
END SUB
