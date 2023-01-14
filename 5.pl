use utf8;
use Encode;

%endings=();

open(dd,"dict.opcorpora.txt");
binmode(dd,":utf8");
while(<dd>){
if(/^([А-ЯЁ][^\t]+)/){
$word=reverse($1);
$len=length($word);
for($q=0;$q<$len;$q++){
$endings{substr($word,0,$q+1)}++;
}

}

if($counter++>500000){last;}
}

open(oo,">endings.txt");
binmode(oo,":utf8");
print oo map{"$_ ($endings{$_})\n"}sort{$endings{$b} <=> $endings{$a}}keys %endings;
