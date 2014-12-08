use strict;
require 'sqf.utils.pl';

my ($bindir, $source, $target) = @ARGV;

die qq(File "mcpp.exe" not found \nPlease get mcpp.exe from http://sourceforge.net/projects/mcpp/\n)
    unless -f "$bindir/mcpp.exe";

die qq(No input sqf-file specified\n)
    unless $source;

die qq(File not found: "$source"\n)
    unless -f $source;

{
    my $sourceScriptName = pathInfo($source)->{file};
    my $preprocessedFilename = $target || "$source.(preprocessed).sqf";
    my $packedFilename       = $target || "$source.(packed).sqf";
    my $minifiedFilename     = $target || "$source.(minified).sqf";
    my $sourceText = readfile($source);
    local *hndlMCPP;
    open (hndlMCPP, qq(| "$bindir/mcpp.exe" -P -+ >$preprocessedFilename));
    print hndlMCPP $sourceText;
    close (hndlMCPP);
    my $packedtext = sqfpack(readfile($preprocessedFilename));
    writefile($packedFilename, $packedtext);
    writefile($minifiedFilename, qq(;Compiled from "$sourceScriptName"\n) . minifyVarNames($packedtext));
}

BEGIN {

    sub sqfpack {
        return sqflockup(shift, sub {
            my $chunk = shift;
            # сжать пробелы и переводы строк
            $chunk =~ s/\s\s+/ /g;
            # сжать пробелы до и после скобок и операторов
            $chunk =~ s/\s*([\{\}\(\)\[\]\<\>\*\/\+\-\,\;\=\!\%])\s*/$1/g;
            # удалить завершающий semicolon
            $chunk =~ s/;\}/\}/g;
            # удалить стартовые пробелы и переводы строк
            $chunk =~ s/^\s+//;
            # удалить финальные пробелы и переводы строк
            $chunk =~ s/\s+$//;
            # удалить некоторые очевидно лишние скобки,
            # которые часто остаются от развернутых макро
            $chunk =~ s/(\w+)\((\w+)\)/$1 $2/g;
            $chunk =~ s/\((\([^\(\)]+\))\)/$1/g;
            $chunk =~ s/\((\([^\(\)]+\))\)/$1/g;
            $chunk =~ s/(\;|\,|\[|\=)\(([^\(\)]+)\)(\;|\,|\])/$1$2$3/g;
            return $chunk;
        });
    }

    my $reservedVariableNames = qr/_time|_this|_x|_forEachIndex|_exception|_pos|_units|_shift|_alt|_id|_uid|_name|_from|_to/;

    sub minifyVarNames {
        my $text = shift;
        my $names = {};
        my $counter = 0;
        $text =~ s/\b(_\w+)\b/_X$1/g;
        $text =~ s{\b(_\w+)\b}{
            my $varname = $1;
            my $varnamelc = lc $varname;
            if ($varname =~ /^_x($reservedVariableNames)\b/i) {
                $varname;
            } else {
                $names->{$varnamelc} = '_' . createname($counter++) unless defined $names->{$varnamelc};
                $names->{$varnamelc};
            }
        }egis;
        $text =~ s/\b_x($reservedVariableNames)\b/$1/gi;
        return $text;
    }

    my @basechars = map { chr $_ } (48 .. 57, 97 .. 119, 122);

    sub intToRadix {
        my ($number, $radix, @range) = @_;
        my $offset = @range && length @range == 1 ? 10 : 0;
        my @chars = @range && length @range > 1 ? map { chr $_ } @range : @basechars;
        my $result = '';
        $radix = 16 unless $radix;
        while ($number) {
            $result = @chars [ $offset + int ( $number % $radix ) ] . $result;
            $number = int ($number / $radix);
        }
        return $result || 0;
    }

    sub createname {
        return intToRadix(shift, 34);
    }
}
