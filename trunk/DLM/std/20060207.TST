// Bei negativen Zeiten von weniger als einer Stunde vergaá TIM, das "-"
// davor zu schreiben.

TstEqual( ntoq(   1,":"),   "  1:00"  )
TstEqual( ntoq( 0.5,":"),   "  0:30"  )
TstEqual( ntoq(-0.5,":"),   " -0:30"  )
TstEqual( ntoq( 0.2,":"),   "  0:12"  )
TstEqual( ntoq(-0.2,":"),   " -0:12"  )
