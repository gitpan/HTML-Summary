package Text::Sentence;

#==============================================================================
#
# Start of POD
#
#==============================================================================

=head1 NAME

Text::Sentence - module for splitting text into sentences

=head1 SYNOPSIS

    use Text::Sentence;
    use locale;
    use POSIX qw( locale_h );

    setlocale( LC_CTYPE, 'iso_8859_1' );
    @sentences = split_sentences( $text );

=head1 DESCRIPTION

The C<Text::Sentence> module contains the function split_sentences, which
splits text into its constituent sentences, based on a fairly approximate
regex. If you set the locale before calling it, it will deal correctly with
locale dependant capitalization to identify sentence boundaries. Certain well
know exceptions, such as abreviations, may cause incorrect segmentations.

=head1 SEE ALSO

=over 4

L<locale>,
L<POSIX>

=back

=head1 AUTHOR

Ave Wrigley E<lt>wrigley@cre.canon.co.ukE<gt>

=head1 COPYRIGHT

Copyright (c) 1997 Canon Research Centre Europe (CRE). All rights reserved.
This script and any associated documentation or files cannot be distributed
outside of CRE without express prior permission from CRE.

=cut

#==============================================================================
#
# End of POD
#
#==============================================================================

#==============================================================================
#
# Pragmas
#
#==============================================================================

require 5.004;
use strict;

#==============================================================================
#
# Modules
#
#==============================================================================

require Exporter;

#==============================================================================
#
# Public globals
#
#==============================================================================

use vars qw( $VERSION @ISA @EXPORT_OK @PUNCTUATION );

$VERSION = '0.006';
@ISA = qw( Exporter );
@EXPORT_OK = qw( split_sentences );
@PUNCTUATION = ( '\.', '\!', '\?' );

#==============================================================================
#
# Public methods
#
#==============================================================================

#------------------------------------------------------------------------------
#
# split_sentences - takes text input an splits it into sentences, based on a
# fairly approximate regex. Returns an array of the sentences.
#
#------------------------------------------------------------------------------

sub split_sentences
{
    my $text = shift;

    return () unless $text;

    # capital letter is a character set; to account for local, this includes
    # all characters for which lc is different from that character

    my $capital_letter =  
        '[' . 
            join( '', 
                grep { lc( $_ ) ne ( $_ ) } 
                map { chr( $_ ) } ord( "A" ) .. ord( "\xff" )
            ) . 
        ']'
    ;

    my $punctuation = '(?:' . join( '|', @PUNCTUATION ) . ')';

    # this needs to be alternation, not character class, because of
    # multibyte characters

    my $opt_start_quote = q/['"]?/; # "'
    my $opt_close_quote = q/['"]?/; # "'

    # these are distinguished because (eventually!) I would like to do
    # locale stuff on quote characters

    my $opt_start_bracket = q/[[({]?/; # }{
    my $opt_close_bracket = q/[\])}]?/;

    # return $text if there is no punctuation ...

    return $text unless $text =~ /$punctuation/;

    my @sentences = $text =~ /
    (
                                # sentences start with ...
        $opt_start_quote        # an optional start quote
        $opt_start_bracket      # an optional start bracket
        $capital_letter         # a capital letter ...
        .+?                     # at least some (non-greedy) anything ...
        $punctuation            # ... followed by any one of !?.
        $opt_close_quote        # an optional close quote
        $opt_close_bracket      # and an optional close bracket
    )
    (?=                         # with lookahead that it is followed by ...
        (?:                     # either ...
            \s+                 # some whitespace ...
            $opt_start_quote    # an optional start quote
            $opt_start_bracket  # an optional start bracket
            $capital_letter     # an uppercase word character (for locale
                                # sensitive matching)
        |               # or ...
            \n\n        # a couple (or more) of CRs
        |               # or ...
            \s*$        # optional whitespace, followed by end of string
        )
    )
    /gxs
    ;
    return @sentences if @sentences;
    return ( $text );
}

#==============================================================================
#
# Return TRUE
#
#==============================================================================

1;