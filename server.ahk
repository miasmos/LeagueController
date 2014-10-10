#Include %A_ScriptDir%\AHKsock.ahk
#SingleInstance IGNORE
; you can change above but you can only have one server for each port so unless you are running multiple servers it will stop a reload without close 
OnExit, CloseAHKsock
sPort = 1000
keyDown = ""
if (sPort="")
    {
    ; you did not send a server Port so i assume you are testing so i will use 27015 for port address
    InputBox, sPort, SERVER PORT, Enter server PORT`n(27015 default), , 170, 200, , , , , 27015
    if ErrorLevel
        ExitApp
    }
loop 512
{
sockets_in_use .=0
}
Gui, Add, ListView, r10 w700 , received|from| on socket
Gui, Add, Text,, Message:
Gui, Add, Edit, vSendthis w300 r1  x+1
Gui, Add, Button, x+1 gGuiBroadcast, Broadcast
Gui, Add, Button, x+1 gGuiSend, or Send to socket
Gui, Add, Edit, vSendsocket w50 r1  x+1
Gui, Add, Button, x+1 gLog, Log
Gui, Add, Button, x+1 gWhoIs, WhoIs
Gui, Show
AHKsock_ErrorHandler("AHKsockErrors")

If (i := AHKsock_Listen(sPort, "Server"))
    {
    If (i = 2)
        {
        ;     2: sFunction is not a valid function.
        msgbox Error:- %i% sFunction is not a valid function , 
        ExitApp
        }
    If (i = 3)
        {
        ;      3: The WSAStartup() call failed. The error is in ErrorLevel.
        msgbox Error:- %i% The WSAStartup() call failed , error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 4)
        {
        ;         4: The Winsock DLL does not support version 2.2.
        msgbox Error:- %i% The Winsock DLL does not support version 2.2. , error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 5)
        {
        ;             5: The getaddrinfo() call failed. The error is in ErrorLevel.
        msgbox Error:- %i% The getaddrinfo() call failed. , error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 6)
        {
        ;           6: The socket() call failed. The error is in ErrorLevel.
        msgbox Error:- %i%  The socket() call failed. , error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 7)
        {
        ;               7: The bind() call failed. The error is in ErrorLevel.
        msgbox Error:- %i%  TThe bind() call failed , error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 8)
        {
        ;                8:  The WSAAsyncSelect() call failed
        msgbox Error:- %i%  The WSAAsyncSelect() call failed, error code = %ErrorLevel% 
        ExitApp
        }
    If (i = 9)
        {
        ;               9:  The listen() call failed. The error is in ErrorLevel.
        msgbox Error:- %i%  The WSAAsyncSelect() call failed, error code = %ErrorLevel% 
        ExitApp
        }
    If (i < 2 or i >9)
        {
        donelog .="Send failed with return value = " i " and ErrorLevel = " ErrorLevel "`n"
        msgbox unknown Error:- %i%, error code = %ErrorLevel%   on socket  %mySocket% 
        ExitApp
        }                
    }
Return
WhoIs:
summary=currently connected sockets`n
loop 512
    {
    if (SubStr(sockets_in_use,a_index , 1) = 1)
        {
        summary.="socket " a_index 
        sName := AHKsock_Sockets("GetName", a_index)
        summary.=" Name " sName 
        sAddr := AHKsock_Sockets("GetAddr",  a_index)
        summary.=" Address "sAddr 
        sPort := AHKsock_Sockets("GetPort",  a_index)
        summary.=" Port " sPort "`n"
        }
    }
msgbox %summary%
return
sendKey(key,double=0) {
    If (double = 1) {
        keywait, %key%
        sleep, 50
        sendinput %key%
    }
    Else {
        Send %key%
    }
    return
}
log:
msgbox %donelog%
return
GuiSend:
GuiControlGet, Sendthis
bSendData=%Sendthis%
GuiControlGet, Sendsocket
bSendDataLength := StrLen(bSendData)  * 2
sendmore(Sendsocket , bSendData , bSendDataLength )
return
GuiBroadcast:
GuiControlGet, Sendthis
bSendData=%Sendthis%
bSendDataLength := StrLen(bSendData)  * 2

Broadcast:
loop 512
    {
    if (SubStr(sockets_in_use,a_index , 1) = 1)
        {
        iSocket :=a_index
        donelog .=  "broadcasting to socket" iSocket ":-" bSendData " which has " bSendDataLength "bytes`n"
        sendmore(iSocket , bSendData , bSendDataLength )
        }
    }
; msgbox %sockets_in_use%
Return
GuiClose:
ExitApp
return
CloseAHKsock:
AHKsock_Close() 
; msgbox %donelog%
; msgbox %recvdtext%

ExitApp
sendmore(iSocket = 0, ByRef bSendData = 0, bSendDataLength = 0)
    {
    Global donelog
    bSendDataSent := 0 
    donelog .=  " `n@"
        Loop
        {
        donelog .="trying to send" bSendData " with " bSendDataLength "bytes, out on socket " iSocket 
        If ((i := AHKsock_Send(iSocket, &bSendData + bSendDataSent, bSendDataLength - bSendDataSent)) < 0)
            {
            If (i = -1)
                {
                ;  -1: WSAStartup hasn't been called yet.
                msgbox Error:- %i% WSAStartup hasn't been called yet , error code = %ErrorLevel%   on socket  %iSocket% 
                break
                }
            If (i = -2)
                {
                ;2: Received WSAEWOULDBLOCK. This means that calling send() would have blocked the thread. we can handle that so add to log
                donelog .="more to send " i 
                }
            If (i = -3)
                {
                ;-3: The send() call failed. The error is in ErrorLevel.
                msgbox Error:- %i% WSAStartup hasn't been called yet , error code = %ErrorLevel%   on socket  %iSocket% 
                break
                }
            If (i = -4)
                {
                ;    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
                msgbox Error:- %i% not a valid socket ,error code = %ErrorLevel%   on socket  %iSocket% 
                break
                }
            If (i = -5)
                {
                ;       -5: The socket specified in iSocket is not cleared for sending. You haven't waited for the SEND event before calling, either ever, or not since you last received WSAEWOULDBLOCK.
                msgbox Error:- %i% Socket is not cleared for sending , error code = %ErrorLevel%   on socket  %iSocket% 
                break
                }
            If (i < -5 or i > -1)
                {
                donelog .="Send failed with return value = " i " and ErrorLevel = " ErrorLevel "`n"
                msgbox unknown Error:- %i%, error code = %ErrorLevel%   on socket  %iSocket% 
                break
                }                
            donelog .="Sent " i " bytes! (loop so far)" a_index
                    }
        Else
            {
            donelog .="Sent " i " bytes! (so far)"
            }   
        ;Check if everything was sent
        If (i < bSendDataLength - bSendDataSent)
            {
            bSendDataSent += i ;Advance the offset so that at the next iteration, we'll start sending from where we left off
            }
        Else
            {
            donelog .="all sent   `n"
            bSendDataSent := 0
            Break ;We're done
            }
        bSendDataSent := 0
        }
    }

Server(sEvent, iSocket = 0, sName = 0, sAddr = 0, sPort = 0, ByRef bRecvData = 0, bRecvDataLength = 0)
    {
    Global done, recvdtext, sockets_in_use, donelog
    Static bDataSent,count
    donelog .=  " `n@"
    donelog .=sEvent 
    If (sEvent = "ACCEPTED")
        {
        donelog .=  "connection requested " sAddr 
        count=0
        sockets_in_use:=SubStr(sockets_in_use, 1, iSocket - 1) . 1 . SubStr(sockets_in_use,iSocket + 1)
        bDataSent := 0 ;Reset bDataSent for the new client
        donelog .=  " successfully connected on IP " sAddr "on socket"  iSocket "`n"
        done=1
        }
    If (sEvent = "DISCONNECTED")
        {
        done=1
        donelog .="The client " sAddr "disconnected `n"
        sockets_in_use:=SubStr(sockets_in_use, 1, (iSocket - 1)) . 0 . SubStr(sockets_in_use, (iSocket + 1))
        }  
    If (sEvent = "SEND" or sEvent = "SENDLAST")
        {    
                Loop
            {
            bData:=msg%count%
            bDataLength := StrLen(bData) * 2
            donelog .="trying to send" bData " with a length of "  bDataLength "bytes `n"
            ;Try to send the data
            If ((i := AHKsock_Send(iSocket, &bData + bDataSent, bDataLength - bDataSent)) < 0)
                {
                ;Check if we received WSAEWOULDBLOCK.
                If (i = -1)
                    {
                    ;  -1: WSAStartup hasn't been called yet.
                    msgbox Error:- %i% WSAStartup hasn't been called yet , error code = %ErrorLevel%   on socket  %iSocket% 
                    ExitApp
                    }
                If (i = -2)
                    {
                    ;2: Received WSAEWOULDBLOCK. This means that calling send() would have blocked the thread. we can handle that so add to log
                    donelog .="more to send " i 
                    Return
                    }
                If (i = -3)
                    {
                    ;-3: The send() call failed. The error is in ErrorLevel.
                    msgbox Error:- %i% WSAStartup hasn't been called yet , error code = %ErrorLevel%   on socket  %iSocket% 
                    ExitApp
                    }
                If (i = -4)
                    {
                    ;    -4: The socket specified in iSocket is not a valid socket. This means either that the socket in iSocket hasn't been created using AHKsock_Connect or AHKsock_Listen, or that the socket has already been destroyed.
                    msgbox Error:- %i% not a valid socket ,error code = %ErrorLevel%   on socket  %iSocket% 
                    ExitApp
                    }
                If (i = -5)
                    {
                    ;       -5: The socket specified in iSocket is not cleared for sending. You haven't waited for the SEND event before calling, either ever, or not since you last received WSAEWOULDBLOCK.
                    msgbox Error:- %i% Socket is not cleared for sending , error code = %ErrorLevel%   on socket  %iSocket% 
                    ExitApp
                    }
                If (i < -5 or i > -1)
                    {
                    donelog .="Send failed with return value = " i " and ErrorLevel = " ErrorLevel "`n"
                    msgbox unknown Error:- %i%, error code = %ErrorLevel%   on socket  %iSocket% 
                    ExitApp
                    }                
                donelog .="Sent " i " bytes! (loop so far)" a_index
                        }
            Else
                {
                donelog .="Sent " i " bytes! (so far)"
                }   
            ;Check if everything was sent
            If (i < bDataLength - bDataSent)
                {
                bDataSent += i ;Advance the offset so that at the next iteration, we'll start sending from where we left off
                }
            Else
                {
                donelog .="all sent   `n"
                count+=1
                bDataSent := 0
                if (StrLen(msg%count%)=0)
                    {
                    Break ;We're done
                    }
                }
            bDataSent := 0
            }
        done=1
        }
    If (sEvent = "RECEIVED")
        {
        recvdtext .= bRecvData
        LV_Add("", bRecvData,sAddr,iSocket)
        donelog .= "recvd this pass:=" bRecvData " in " bRecvDataLength " bytes.`ntotal recvd " recvdtext "`n"

        If (bRecvData = "FOCUSSUMMONER1BLUE") {
            sendKey(1,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER2BLUE") {
            sendKey(2,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER3BLUE") {
            sendKey(3,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER4BLUE") {
            sendKey(4,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER5BLUE") {
            sendKey(5,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER1PURPLE") {
            sendKey(Q,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER2PURPLE") {
            sendKey(W,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER3PURPLE") {
            sendKey(E,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER4PURPLE") {
            sendKey(R,1)
        }
        Else If (bRecvData = "FOCUSSUMMONER5PURPLE") {
            sendKey(T,1)
        }
        Else If (bRecvData = "FOGOFWARBLUE") {
            sendKey(F1,0)
        }
        Else If (bRecvData = "FOGOFWARPURPLE") {
            sendKey(F2,0)
        }
        Else If (bRecvData = "FOGOFWARALL") {
            sendKey(F3,0)
        }
        Else If (bRecvData = "TOGGLETEAMFIGHTUI") {
            sendKey(A,0)
        }
        Else If (bRecvData = "TOGGLESCOREBOARD") {
            sendKey(X,0)
        }
        Else If (bRecvData = "TOGGLEUI") {
            sendKey(H,0)
        }
        Else If (bRecvData = "MANUALCAMERA") {
            sendKey(S,0)
        }
        Else If (bRecvData = "DIRECTEDCAMERA") {
            sendKey(D,0)
        }
        done=1
        }
    If (sEvent = "SENDLAST")
        {
        donelog .="The client " sAddr "is closing ,so clear whats left to send `n"
        done=1
        }
    if (done<>"1")
        {
        donelog .="Server - Closing"  sAddr "`n"
        If (i := AHKsock_Close(iSocket))
            {
            donelog .="close failed"   ErrorLevel
            sockets_in_use:=SubStr(sockets_in_use, 1, (iSocket - 1)) . 0 . SubStr(sockets_in_use, (iSocket + 1))
            }
        }
    done=
    }
AHKsockErrors(iError, iSocket)
    {
    donelog .="Error " iError " with error code = " ErrorLevel  " on socket " iSocket  "`n"
    detail_msg =
    if (ErrorLevel=6)
        detail_msg =WSA_INVALID_HANDLE.Specified event object handle is invalid.
    if (ErrorLevel=8)
        detail_msg =WSA_NOT_ENOUGH_MEMORY.Insufficient memory available.
    if (ErrorLevel=87)
        detail_msg =WSA_INVALID_PARAMETER.One or more parameters are invalid.
    if (ErrorLevel=995)
        detail_msg =WSA_OPERATION_ABORTED.Overlapped operation aborted.
    if (ErrorLevel=996)
        detail_msg =WSA_IO_INCOMPLETE.Overlapped I/O event object not in signaled state.
    if (ErrorLevel=997)
        detail_msg =WSA_IO_PENDING.Overlapped operations will complete later.
    if (ErrorLevel=10004)
        detail_msg =WSAEINTR.Interrupted function call.
    if (ErrorLevel=10009)
        detail_msg =WSAEBADF.File handle is not valid.
    if (ErrorLevel=10013)
        detail_msg =WSAEACCES.Permission denied.
    if (ErrorLevel=10014)
        detail_msg =WSAEFAULT.Bad address.
    if (ErrorLevel=10022)
        detail_msg =WSAEINVAL.Invalid argument.
    if (ErrorLevel=10024)
        detail_msg =WSAEMFILE.Too many open files.
    if (ErrorLevel=10035)
        detail_msg =WSAEWOULDBLOCK.Resource temporarily unavailable.
    if (ErrorLevel=10036)
        detail_msg =WSAEINPROGRESS.Operation now in progress.
    if (ErrorLevel=10037)
        detail_msg =WSAEALREADY.Operation already in progress.
    if (ErrorLevel=10038)
        detail_msg =WSAENOTSOCK.Socket operation on nonsocket.
    if (ErrorLevel=10039)
        detail_msg =WSAEDESTADDRREQ.Destination address required.
    if (ErrorLevel=10040)
        detail_msg =WSAEMSGSIZE.Message too long.
    if (ErrorLevel=10041)
        detail_msg =WSAEPROTOTYPE.Protocol wrong type for socket.
    if (ErrorLevel=10042)
        detail_msg =WSAENOPROTOOPT.Bad protocol option.
    if (ErrorLevel=10043)
        detail_msg =WSAEPROTONOSUPPORT.Protocol not supported.
    if (ErrorLevel=10044)
        detail_msg =WSAESOCKTNOSUPPORT.Socket type not supported.
    if (ErrorLevel=10045)
        detail_msg =WSAEOPNOTSUPP.Operation not supported.
    if (ErrorLevel=10046)
        detail_msg =WSAEPFNOSUPPORT.Protocol family not supported.
    if (ErrorLevel=10047)
        detail_msg =WSAEAFNOSUPPORT.Address family not supported by protocol family.
    if (ErrorLevel=10048)
        detail_msg =WSAEADDRINUSE.Address already in use.
    if (ErrorLevel=10049 )
        detail_msg =WSAEADDRNOTAVAIL.Cannot assign requested address. 
    if (ErrorLevel=10050)
        detail_msg =WSAENETDOWN.Network is down.
    if (ErrorLevel=10051 )
        detail_msg =WSAENETUNREACH.Network is unreachable.
    if (ErrorLevel=10052 )
        detail_msg =WSAENETRESET.Network dropped connection on reset
    if (ErrorLevel=10053 )
        detail_msg =WSAECONNABORTED. Software caused connection abort.
    if (ErrorLevel=10054 )
        detail_msg = WSAECONNRESET. Connection reset by peer.
    if (ErrorLevel=10055 )
        detail_msg = WSAENOBUFS. No buffer space available.
    if (ErrorLevel=10056 )
        detail_msg =WSAEISCONN. Socket is already connected.
    if (ErrorLevel=10057 )
        detail_msg =WSAENOTCONN. Socket is not connected.
    if (ErrorLevel=10058 )
        detail_msg =WSAESHUTDOWN.Cannot send after socket shutdown.
    if (ErrorLevel=10059 )
        detail_msg =WSAETOOMANYREFS.Too many references.
    if (ErrorLevel=10060 )
        detail_msg =WSAETIMEDOUT. Connection timed out. 
    if (ErrorLevel=10061)
        detail_msg =WSAECONNREFUSED.Connection refused.
    if (ErrorLevel=10062 )
        detail_msg =WSAELOOP.Cannot translate name.
    if (ErrorLevel=10063 )
        detail_msg =WSAENAMETOOLONG. Name too long.
    if (ErrorLevel=10064 )
        detail_msg =WSAEHOSTDOWN. Host is down.
    if (ErrorLevel=10065 )
        detail_msg =WSAEHOSTUNREACH.  No route to host.
    if (ErrorLevel=10066 )
        detail_msg =WSAENOTEMPTY. Directory not empty.
    if (ErrorLevel=10067 )
        detail_msg = WSAEPROCLIM. Too many processes.
    if (ErrorLevel=10068 )
        detail_msg =WSAEUSERS. User quota exceeded.
    if (ErrorLevel=10069 )
        detail_msg =WSAEDQUOT. Disk quota exceeded.
    if (ErrorLevel=10070 )
        detail_msg =WSAESTALE. Stale file handle reference.
    if (ErrorLevel=10071 )
        detail_msg =WSAEREMOTE. Item is remote.
    if (ErrorLevel=10091 )
        detail_msg =WSASYSNOTREADY.Network subsystem is unavailable.
    if (ErrorLevel=10092 )
        detail_msg =WSAVERNOTSUPPORTED. Winsock.dll version out of range.
    if (ErrorLevel=10093 )
        detail_msg =WSANOTINITIALISED. Successful WSAStartup not yet performed.
    if (ErrorLevel=10101 )
        detail_msg =WSAEDISCON. Graceful shutdown in progress.
    if (ErrorLevel=10102 )
        detail_msg =WSAENOMORE. No more results.
    if (ErrorLevel=10103 )
        detail_msg =WSAECANCELLED.Call has been canceled.
    if (ErrorLevel=10104)
        detail_msg =WSAEINVALIDPROCTABLE.Procedure call table is invalid.
    if (ErrorLevel=10105)
        detail_msg =WSAEINVALIDPROVIDER.Service provider is invalid.
    if (ErrorLevel=10106)
        detail_msg =WSAEPROVIDERFAILEDINIT.Service provider failed to initialize.
    if (ErrorLevel=10107)
        detail_msg =WSASYSCALLFAILURE.System call failure.
    if (ErrorLevel=10108)
        detail_msg =WSASERVICE_NOT_FOUND.Service not found.
    if (ErrorLevel=10109)
        detail_msg =WSATYPE_NOT_FOUND.Class type not found.
    if (ErrorLevel=10110)
        detail_msg =WSA_E_NO_MORE.No more results.
    if (ErrorLevel=10111)
        detail_msg =WSA_E_CANCELLED.Call was canceled.
    if (ErrorLevel=10112)
        detail_msg =WSAEREFUSED.Database query was refused.
    if (ErrorLevel=11001)
        detail_msg =WSAHOST_NOT_FOUND.Host not found.
    if (ErrorLevel=11002)
        detail_msg =WSATRY_AGAIN.Nonauthoritative host not found.
    if (ErrorLevel=11003)
        detail_msg =WSANO_RECOVERY.This is a nonrecoverable error.
    if (ErrorLevel=11004)
        detail_msg =WSANO_DATA.Valid name, no data record of requested type.
    if (ErrorLevel>11004 and ErrorLevel<11032)
        detail_msg = WSA_QOS_.......Invalid QoS.......
    ; more info available at :-http://msdn.microsoft.com/en-us/library/ms740668
    msgbox Error %iError% with error code = %ErrorLevel%   on socket  %iSocket%- %detail_msg%
    ExitApp
    }