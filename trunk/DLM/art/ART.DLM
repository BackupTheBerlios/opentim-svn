// Artikelstammdaten Standardmodul
CustData ART GRA

LenIdArt    6
LenRefExt  15
LenArtRoot  2
LenArtName 40
LenGraName 40
LenIdGra    3

// VNL->Code will be set to "T" if trim(IdArt) is "=" (instead of
// default "T")
ArtIsTotal {|x|trim(x)=="="}
PicIdArt "@k@!"

LenIdPga    1
LenIdUnt    3

