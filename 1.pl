use utf8;
use HTML::Entities;

open(dd,"1.json");
read(dd,$file,-s(dd));

$file=~s/[\r\n]+//gs;
$file=decode_entities($file);
$file=~s/\\u([\da-f]{4})/chr(hex($1))/iesg;

print $file;