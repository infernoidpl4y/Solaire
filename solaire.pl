#!/usr/bin/perl
#use strict;
use warnings;
use v5.42;
use feature "say";
use Path::Tiny;
use lib "modules";

sub parser{
	my ($code)=@_;
	if($code=~/IMPORT IN (\w+)/){
		$code=~s/IMPORT IN (\w+)/use feature \"$1\"/g;
	}else{
		$code=~s/IMPORT (\w+)/use $1/g;
	}
	$code=~s/\@(\w+)/\$$1/g;
	$code=~s/\&(\w+)/\@$1/g;
	$code=~s/VAR/my/g;
	$code=~s/FUNC\s+(\w+)\s*\(([^)]+)\)\s*\$\>/sub $1\{\n   my \($2\)=\@_;/g;
	$code=~s/RET\s+([^)]+)/return $1/g;
	$code=~s/\<\$/\}/g;
	$code=~s/log\(([^)]+)\)/f_log\($1\)/g;
	$code=~s/SI\s*\(([^)]+)\)\s*\$\>/if\($1\)\{/g;
	$code=~s/SINO\s*\$\>/else\{/g;
	$code=~s/PORCADA\s*\(([^)]+)\s+EN\s+([^)]+)\)\s*\$\>/foreach $1 \($2\)\{/g;
	$code=~s/POR\s*\(([^)]+);([^)]+);([^)]+)\)\s*\$\>/for\($1;$2;$3\)\{/g;
	$code=~s/ABRIR\s*\(([^)]+)\)/path\($1\)\-\>slurp_utf8/g;
	return $code;
}

my $file=$ARGV[0];
if($file eq "-v"){
	say "Solaire v1.0";
	exit;
}
my $input=path($file)->slurp_utf8;

eval parser($input);
if($@){
	say "$@";
}
