[etc if !empty(VEN->NB1)]
[B][=tr("Subject:","Betreff:","Concerne:")][b] [=trim(VEN->NB1)]

[etc endif]
[etc if VEN->IdJnl$"BST"]
We order as follows :
[etc endif]
[etc if VEN->IdJnl$"DON"]
We confirm receipt for the following donations :
[etc endif]
[etc if VEN->IdJnl$"VKA,AUF"]
Wir danken Ihnen fr Ihre Preisanfrage und m”chten Ihnen folgendes Angebot
unterbreiten.

[etc endif]
