use strict;
require 'sqf.utils.pl';

my $sourcefilename = shift;
my $targetfilename = shift;
my $text = readfile($sourcefilename);

$text =~ s{^(\s*)(\w+)\s*=\s*"([\d\s\(\)\.\*\/\+\-]+)"\s*;\s*$}{
    cnvLine($&, $1, $2, $3);
}egim;

writefile($targetfilename, $text);

sub cnvLine {
    my ($oldLine, $indent, $propertyName, $stringValue) = @_;
    return $oldLine if $propertyName =~ /(startDate|format\w)/;
    $stringValue =~ s/\s+//g;
    my $newLineCompact = qq($indent$propertyName = "$stringValue";);
    my $result = eval($stringValue);
    unless (defined $result) {
        print "\n>> Failed trying eval value: $@ <$newLineCompact>\n";
    };

    my $newLineCompiled = qq($indent$propertyName = $result;);
    my $newLine = defined $result ? $newLineCompiled : $newLineCompact;

    print sprintf(
        qqq("
            --- replace ---------------------------------------------------------

                original %s :$oldLine
                compact  %s :$newLineCompact
                compiled %s :$newLineCompiled
        "),
        "   ",
        defined $result ? "   " : ">>>",
        defined $result ? ">>>" : "   "
    );

    return $newLine;
}
