#!/usr/bin/perl
# bug 6335: ips_only URIDNSBL rules

use lib '.'; use lib 't';
use SATest; sa_t_init("uribl_ips_only");

use constant TEST_ENABLED => conf_bool('run_net_tests') && conf_bool('run_long_tests');
use constant DO_RUN => TEST_ENABLED && can_use_net_dns_safely();
use Test;

BEGIN {
  plan tests => (DO_RUN ? 2 : 0),
};

exit unless (DO_RUN);

# ---------------------------------------------------------------------------

%anti_patterns = (
 q{ X_URIBL_IPSONLY } => 'A',
);

tstlocalrules(q{

  rbl_timeout 30

  urirhssub  X_URIBL_IPSONLY  dnsbltest.spamassassin.org.    A 2
  body       X_URIBL_IPSONLY  eval:check_uridnsbl('X_URIBL_IPSONLY')
  tflags     X_URIBL_IPSONLY  net ips_only

  add_header all RBL _RBL_

});

# note: don't leave -D here, it causes spurious passes
ok sarun ("-t < data/spam/dnsbl_ipsonly.eml 2>&1", \&patterns_run_cb);
ok_all_patterns();

