#!/usr/bin/perl
#use strict;
use warnings;
use v5.42;
use feature "say";
use Path::Tiny;
use lib "modules";

sub parser{
	my ($code)=@_;
	if($code=~/IMPORTAR FE (\w+)/){
		$code=~s/IMPORTAR FE (\w+)/use feature \"$1\"/g;
	}else{
		$code=~s/IMPORTAR (\w+)/use $1/g;
	}
	$code=~s/\@(\w+)/\$$1/g;
	$code=~s/\&(\w+)/\@$1/g;
	$code=~s/VAR/my/g;
	$code=~s/FUNCION\s+(\w+)\s*\(([^)]*)\)\s*\$\>/sub $1\{\n   my \($2\)=\@_;/g;
	$code=~s/RETORNAR\s+([^)]+)/return $1/g;
	$code=~s/\<\$/\}/g;
	$code=~s/\s+ESCRIBIR\s*\(([^)]+)\)/print $1,\"\\n\"/g;
	$code=~s/SI\s*\(([^)]+)\)\s*\$\>/if\($1\)\{/g;
	$code=~s/SINO\s*\$\>/else\{/g;
	$code=~s/PORCADA\s*\(([^)]+)\s+EN\s+([^)]+)\)\s*\$\>/foreach $1 \($2\)\{/g;
	$code=~s/POR\s*\(([^)]+);([^)]+);([^)]+)\)\s*\$\>/for\($1;$2;$3\)\{/g;
	$code=~s/a_ABRIR\s*\(([^)]+),UTF8\)/path\($1\)\-\>slurp_utf8/g;
	$code=~s/a_ABRIR\s*\(([^)]+),ESCL\)/path\($1\)\-\>slurp/g;
	$code=~s/a_ABRIR\s*\(([^)]+),LISTA\)/path\($1\)\-\>lines/g;
	$code=~s/a_ESCRIBIR\s*\(([^)]+),([^)]+)\)/path\($1\)\-\>spew\($2\)/g;
	$code=~s/a_AGREGAR\s*\(([^)]+),\"([^)]+)"\)/path\($1\)\-\>append\(\"\\n$2\"\)/g;
	$code=~s/a_COPIAR\s*\(([^)]+),([^)]+)\)/path\($1\)\-\>copy\($2\)/g;
	$code=~s/a_MOVER\s*\(([^)]+),([^)]+)\)/path\($1\)\-\>move\($2\)/g;
	$code=~s/a_ELIMINAR\s*\(([^)]+)\)/path\($1\)\-\>remove/g;
	
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
