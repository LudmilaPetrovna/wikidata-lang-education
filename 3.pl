use utf8;
use JSON;
use Encode;
use HTML::Entities;

%words=();

open(oo,">freq.log");
binmode(oo,":utf8");

$/="</doc>";

open(dd,"ruwiki-20230101-abstract.xml");
while(<dd>){
$file=$_;

if($file=~/<abstract[^>]*>(.+?)<\/abstract>/s){
$text=lc(decode_utf8($1));

$text=~s/́//gs;
$text=~s/ё/е/gs;
#$text=~s/[\d\-\=\!@"#\$\%^&\*\?\|:\.,\+()\[\]\{\}]+/ /gs;
$text=~s/[\W\d_]+/ /gs;

map{$words{$_}++}split(/\s+/,$text);

$out.="$text\n";


#print encode("cp866",$out);
#print oo $out;

if((($counter++)%12345)==0){
print "Position at ".tell(dd)."\n";
}

}
}

print oo map{"$_ ($words{$_})\n"}sort{$words{$b} <=> $words{$a}}keys %words;



