#!/usr/bin/perl
#use strict;
use warnings;
use v5.42;
use feature "say";
use Path::Tiny;
use lib "modules";

sub parser{
	my ($code)=@_;
	#Import
	if($code=~/IMPORT IN (\w+)/){
		$code=~s/IMPORT IN (\w+)/use feature \"$1\"/g;
	}else{
		$code=~s/IMPORT (\w+)/use $1/g;
	}
	#Variables
	$code=~s/\@(\w+)/\$$1/g;
	$code=~s/VAR/my/g;
	#funciones FUNC ^
	$code=~s/FUNC\s+(\w+)\s*\(([^)]+)\)\s*\$\>/sub $1\{\n   my \($2\)=\@_;/g;
	$code=~s/\<\$/\}/g;
	#Input Y Output
	$code=~s/log\(([^)]+)\)/f_log\($1\)/g;
	#Condiciones
	$code=~s/SI\s*\(([^)]+)\)\s*\$\>/if\($1\)\{/g;
	$code=~s/SINO\s*\$\>/else\{/g;
	
	return $code;
}

my $file=$ARGV[0];
my $input=path($file)->slurp_utf8;

eval parser($input);
say parser($input);
if($@){
	say "$@";
}
