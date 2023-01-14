use utf8;
use JSON;
use Encode;
use HTML::Entities;
use Data::Dumper;

@langs=qw/ru-en ru-kk ru-en-de ru-ja ru-uk ru-pl ru-ka/;
map{$langsall{$_}++}map{split(/-/)}@langs;
@langsall=sort keys %langsall;
print "Creating dicts for ".join(" ", @langsall)."\n";

%fds=();
map{my $ff;open($ff,">dict-$_.txt");binmode($ff,":utf8");$fds{$_}=$ff}@langs;

$/="</page>";

open(dd,"v:/buggy1.json");
read(dd,$file,-s(dd));
processJson($file);


#die;
open(dd,"cat wikidatawiki-20230101-pages-articles.xml.bz2| bzip2 -d |");
####open(dd,"wikidatawiki-20230101-pages-articles1.xml-p1p441397");
while(<dd>){
$file=$_;

if(index($file,'<format>application/json</format>')<0){next;}

if($file=~/<text[^>]*>(.+?)<\/text>/s){
processJson($1);
}

}







sub processJson{
my $text=shift;
my @ln;
my $langpair;
my %cols;
my %spaces=();
$text=~s/[\r\n]+//gs;

open(zz,">v:/wikidebug.json");
print zz $text;
close(zz);

$text=decode_entities($text);

open(zz,">v:/wikidebug-noentities.json");
print zz $text;
close(zz);

my $json=decode_json($text);

open(zz,">v:/wikidebug.pl");
print zz Dumper($json);
close(zz);

if(!$json || !$json->{labels} || ref($json->{labels}) ne "HASH"){next;}
$haveDescr=($json->{descriptions} && ref($json->{descriptions}) eq "HASH")?1:0;

%cols=();
%colsw=();

foreach $id(@langsall){
if($json->{labels}->{$id}){

my $en=$json->{labels}->{$id}->{value};
if($en=~/Wiki/i){next;} # no "wiki" in texts
if($en=~/\d/){next;} # no numbers in texts
if($id eq "ru" && $en=~/[a-z]/i){next;} # no english letters in russian language
#if($ru=~/^[А-ЯЁ]/){next;}
#if(length($ru)>5 && length($en)>5){next;}
$cols{$id}=$en;
$colsw{$id}=lc($en);
$spaces{$id}=($en=~tr/ / /);

if($haveDescr && $json->{descriptions}->{$id}){
$cols{$id}.=" ($json->{descriptions}->{$id}->{value})";
}

}
}


foreach $langpair(@langs){
#print "langpair $langpair\n";
@ln=split(/-/,$langpair);
$badpair=0;
map{$badpair++}grep{$cols{$_} eq ""}@ln;
if($badpair){next;}

if(@ln==2 && $colsw{$ln[0]} eq $colsw{$ln[1]}){next;}
if(@ln==2 && $spaces{$ln[0]} != $spaces{$ln[1]}){next;}

$out=join("\t",map{$cols{$_}}@ln)."\n";

#print "$langpair=".encode("cp866",$out);
$fd=$fds{$langpair};
print $fd $out;
}
# out last part to screen
#print encode("cp866",$out);

#$file=~s/\\u([\da-f]{4})/chr(hex($1))/iesg;
#if($json->{labels}->{ru} && $json->{labels}->{en}){
#exit;
#}
}


