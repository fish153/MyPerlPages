#!/usr/bin/perl

use CGI::Pretty qw/:standard/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
require 'mysubs.pm';

my $greeting = 'Hi there ';
my $curtime = 'Give your name to see the time';
my $catMessage;
# text field for the firt name
#
	my $firstNameForm = &FirstNameField;

# text field for the last name
	my $lastNameForm = &LastNameField;


# fetch first and last names
	my $fname = param('first');	
	my $lname = param('last');
param('look') and $look = param('look');
if($look =~ /cat|dog/i){
		$catMessage = &LookPic($look);
		$greeting .= $fname . ' ' . $lname;
		$curtime = &ttime;
}
# check if submit first name button has been clicked
# if so check first name 
# if first name has no mistake assign last name form to the current form
elsif(param('fsubmit') ne ''){

	if($fname =~ /^[a-zA-Z]*$/){
		$currentForm = $lastNameForm;
	       
	}
	else {				
			# if first name has different characters than letters
			# print first name form again and send alert
		$message = 
		div( {-class=>'alert'}, "Name should contain letters only");
		$currentForm = $firstNameForm;
	}
}
# 
# check if last name has been sent	
elsif(param('lsubmit') ne ''){
	#check last name - should contain letters, a dash or a single qoute only
		if($lname =~ /^[a-zA-Z]+[.'-]?[a-zA-Z]+$/){
		# if name is good, 		
		$message = h3('Dear, ' . $fname . ' ' . $lname . ':'); 
		$currentForm = 	hidden('last', $last) .
		hidden('first', $first);

		# if names are fetched and have letters and/or dash or a single quote only
		# assign it to the greeting
		# 
		$greeting .= $fname . ' ' . $lname;
		$curtime = &ttime;
		$catMessage = &CatDay($fname, $lname);
		}
		else {
			# if name is no good - send a message
			# print form again
			$message = 
			div( {-class=>'alert'}, 
				"Name should contain letters,
			       	a dash and apostrophie only");
			$currentForm = $lastNameForm;
		}


}

else {
	# if no triggers activated - show firt name text field
	$currentForm = 	$firstNameForm;
}

Delete_all();

$title = 'Hidden, Subroutines and Time';

# call &top to print top of the page with  title and greetings
&top($title, $greeting, $curtime);

print	div({ -class=>'main'},
	$message,
	$catMessage,
	start_form( -method=>'post', -action=>''),
	$currentForm,



	end_form
	),
	end_html;




