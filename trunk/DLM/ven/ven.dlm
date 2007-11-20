// Verkaufsrechnungen
CustData VEN VNL

LenLstVen  30
LenIdMfc    3
LenVnlName 60  // length of field VNL->Libell
// VnlTotBegin gives an additional condition about what VNL-lines in a
// document serve as start marker. By default, only T- or #-lines
// serve as start delimiter. Previous T-lines are exclusive
// (not part of the subsequent subtotal), but #-lines are inclusive.
VnlTotBegin {||left(VNL->IdArt,1)=="+"}


VnlIdValidate !VNL->Code$"AF".or.!"H"$ART->Attrib.or.val(ART->IdArt)==0\
  .or.Warning(ArtName() + utr(": hidden article",\
      ": versteckter Artikel",": article invisible!"))
