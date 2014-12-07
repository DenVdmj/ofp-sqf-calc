
sub sqflockup {
    my ($text, $sub) = @_;
    my $even = !0;
    # only for code, but ain`t for a string value
    $text =~ s{(")|([^"]*?)(?="|$)}{
        my $quote = $1;
        my $chunk = $2;
        $even = !$even unless $quote eq "";
        # if current chunk is a code, but not string constant
        $chunk = $sub->($chunk) if $even;
        $quote . $chunk;
    }egs;
    return $text;
}

sub loadSQFCommands {
    my ($filename) = @_;
    local *file;
    open(*file, $filename) or return undef;
    my %commands = map { chomp; lc $_, $_ } <file>;
    close(*file);
    return \%commands;
}

sub readfile {
    my ($filename, $binmode) = @_;
    local *file;
    open(*file, $filename) or return undef;
    binmode *file if $binmode;
    my $string;
    sysread(*file, $string, -s *file);
    close(*file);
    return $string;
}

sub writefile {
    my ($filename, $contents, $binmode) = @_;
    local *file;
    open(*file, "+>$filename");
    binmode *file if $binmode;
    syswrite(*file, $contents, length $contents);
    close(*file);
}

sub qqq {
    my $string = shift;
    my ($indent) = $string =~ /^\n(\x20+)/;
    $string =~ s/$indent//gm;
    return $string;
}

sub pathInfo {
    my @path = split(/\\|\//, shift);
    my $fileIndex = @path - 1;
    my $file = @path[$fileIndex];
    my $extPosition = rindex($file, '.');
    $extPosition = length $file if $extPosition <= 0;
    return {
        item => \@path,
        path => join('/', @path),
        disk => @path[0] =~ m/^[A-Za-z]\:$/ ? @path[0] : '',
        file => $file,
        dir  => join('/', (@path[0 .. $fileIndex-1], '')),
        name => substr($file, 0, $extPosition),
        ext  => substr($file, 1+ $extPosition)
    }
}

sub foreachdirs {
    # ( path => string, open => sub, proc => sub, close => sub, sort => sub )
    # ( path, open => sub, proc => sub, close => sub, file => sub, sort => sub )

    my %option = @_;
    my $deep = 0;

    my $_traversal;
    $_traversal = sub {

        my ($path) = @_;

        $option {'proc'} -> ($path, $deep) if $option {'proc'};
        $option {'file'} -> ($path, $deep) if -f $path and $option {'file'};
        $option {'open'} -> ($path, $deep) if -d $path and $option {'open'};

        return unless -d $path;

        local *DIR;

        opendir(*DIR, $path) or die;

        my @filelist = sort {
            -d $path . '\\' . $b cmp -d $path . '\\' . $a
        } readdir(*DIR);

        closedir(*DIR);

        foreach my $filename (@filelist) {
            next if $filename eq '.' or $filename eq '..';
            $deep++;
            $_traversal->($path . '\\' . $filename);
            $deep--;
        }

        $option {'close'} -> ($path, $deep) if $option {'close'};
    };

    $_traversal->( $option {'path'} );
}

1;

