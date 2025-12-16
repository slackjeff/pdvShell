PROCEDURE Main( cMsg )

   LOCAL nTop, nLeft, nBottom, nRight
   LOCAL cScr

   IF Empty( cMsg )
      cMsg := "Mensagem"
   ENDIF

//   SET COLOR TO "W/B"
   SET CURSOR OFF

   nTop    := Int( ( MaxRow() - 3 ) / 2 )
   nLeft   := Int( ( MaxCol() - Len( cMsg ) - 4 ) / 2 )
   nBottom := nTop + 2
   nRight  := nLeft + Len( cMsg ) + 3

   // >>> ISSO É O SEGREDO <<<
   @ nTop, nLeft CLEAR TO nBottom, nRight

   cScr := SaveScreen( nTop, nLeft, nBottom, nRight )

   DispBegin()
      DispBox( nTop, nLeft, nBottom, nRight )
      @ nTop + 1, nLeft + 2 SAY cMsg
   DispEnd()

   Inkey(0)

   RestScreen( nTop, nLeft, nBottom, nRight, cScr )

RETURN
