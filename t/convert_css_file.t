use strict;

use Test::More 'no_plan';

use HTML2XHTML;

my $convert = new HTML2XHTML(file_name => 'try.css');
ok($convert, "1 CSS document successfully converted");

# ----------------------------------------------------------------
;1;
# ----------------------------------------------------------------

