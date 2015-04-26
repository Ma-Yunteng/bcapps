#!/bin/perl

# Writes (and runs?) an iMacro script to create a FetLife user and log
# it in, in order to obtain a session cookie

require "/usr/local/lib/bclib.pl";

# TODO: create $nickname, $email, $password

# this creates fields with no repeated letters (which is unnecessary but silly)
my(@list) = ("a".."z");

my(@r) = randomize(\@list);

$nickname = join("",@r[0..6]);
$email = join("",@r[7..12]);
$email_domain = join("",@r[13..19]);
$password = join("",@r[20..25]);

print << "MARK";
TAB T=1
URL GOTO=https://fetlife.com/signup
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_nickname CONTENT=$nickname
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_sex CONTENT=%M
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_sexual_orientation CONTENT=%Straight
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_role CONTENT=%Dominant
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_date_of_birth_1i CONTENT=%1939
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_country_id CONTENT=%7
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_administrative_area_id CONTENT=%103
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_email CONTENT=$email
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_email_confirmation CONTENT=$email
TAG POS=1 TYPE=INPUT:PASSWORD FORM=ACTION:/users ATTR=ID:user_password CONTENT=$password
TAG POS=1 TYPE=INPUT:PASSWORD FORM=ACTION:/users ATTR=ID:user_password_confirmation CONTENT=$password
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_spam_check_foo CONTENT=7
TAG POS=1 TYPE=INPUT:CHECKBOX FORM=ACTION:/users ATTR=ID:user_terms_and_conditions CONTENT=YES
! pause for captcha
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ID:new_user ATTR=NAME:commit&&VALUE:Join<SP>FetLife
MARK
;
