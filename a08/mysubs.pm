###################################################################################
####             BROWSER DETECTION   ####################################
sub browser{

	
my $browser =$ENV{'HTTP_USER_AGENT'};


if ($browser =~ m/Trident/){
	$class = "trident";
	$info = "Your browser is Internet Explorer\n";
}
elsif ($browser =~ m/Chrome/){
	$class = "chrb";
	$info = "Your browser is Google Chrome\n";
}
elsif ($browser =~ m/Opera/){
	$class = "opb"; 
	$info = "Your browser is Opera\n";
}
elsif ($browser =~ m/Firefox/){
	$class = "ffb"; 
	$info = "Your browser is Mozilla Firefox\n";
}
else {
	$class = "whocares"; 
	$info = "No one really cares about you browser\n";
}

	my @values = ($class, $info);
	return @values;
}


#################################################
# 		print top of the page		#
# ###############################################
sub top {
        my $title =  $_[0];
        my $header = $_[1];
        my $subheader = $_[2];

# hash keeps links of the main menu
my %menu = (
			"01"	=>	[qw(JS&nbsp;Basics ../a01/)],
			"02"	=>	[qw(Browser	../a02/)],
			"03"	=>	[qw(Slideshow	../a03)], 
			"04"	=>	[qw(Windows	../a04)],
			"05"	=>	[qw(Forms 	../a05)],
			"06"	=>	[qw(Perl&nbsp;Basics	../a06)], 
			"07"	=>	[qw(Param	../a07)],
			"08"	=>	[qw(Hidden	../a08)],
			"09"	=>	[qw(Sort	../a09)],
			"10"	=>	[qw(Add		../a10)],
			"11"	=>	[qw(Project	../a11)]
	);


for my $key(sort keys %menu){$list .=  li( a({-href=>$menu{$key}[1]}, $menu{$key}[0])) };


	############################
	#       PAGE STARTS HERE   #
	############################
print 	header; 
print	start_html(
		-title=>$title,
		-head=>[Link({-rel=>'stylesheet',
				-href=>'../css/base.css'}),
			Link({-rel=>'stylesheet',
				-href=>'http://fonts.googleapis.com/css?family=Lobster&subset=latin,cyrillic'}),
			Link({-rel=>'stylesheet',
				-href=>'http://fonts.googleapis.com/css?family=Source+Sans+Pro:300,900,900italic'}),
			Link({-rel=>'stylesheet',
				-href=>'"http://fonts.googleapis.com/css?family=Source+Sans+Pro:900&effect=anaglyph|fire-animation'})
			]
		);

	#########################
	#			#	
	#     Floating Orange	#
	#########################	
print	div({-class=>'roller'},
		img({-src=>'../css/forange.png', -alt=>'an orange'})
	);
	#########################
	#			#
	#   HEADER GOES HERE	#
	#########################
print	div({ -class=>'top'},
		div({ -class=>'topbar'},
			h1($header),
			h3({ -class=>'font-effect-anaglyph'}, $subheader)
		)
	);

	#################################
	#	NAVIGATION MENU		#
	#				#
	#################################
print	div({ -class=>'navbar'},
		ul(
			$list #print menu stored in the variable $list
		)
                );
}

#################################################
# 	subroutine to 				#
#	return local time			#
#################################################
sub ttime {
	my @months = qw(January February March April May June July August September October November December);
	my @day = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
	($seconds, $minutes, $hours, $date, $month, $year, $week, $dyear, $savings) = (localtime) [0,1,2,3,4,5,6,7,8];
	$year += 1900;
# Have it print the time out like this: 
# November 25, 2011 18:05:02;
	$time = $months[$month] . ' ' . $date . ', ' . $year . ' ' .  $hours . ':' . $minutes . ':' . $seconds . ' ' . $day[$week];
	return $time;
}

#################################################
#						#
#		FIRST NAME Text Field		#
#################################################

sub FirstNameField {
	my $field = 
	"First Name: " . 
	textfield(-name=>'first', -size=>20, -default=>'', -placeholder=>'First Name', -maxlength=>40) .
	submit(-name=>'fsubmit', -value=>'Submit First Name');
	return $field;
}

sub LastNameField {
	my $field =
	"Last Name: " .
	hidden('first', $first) .
	textfield(-name=>'last', -size=>20, -default=>'', -placeholder=>'Last Name', -maxlength=>40) . 
	submit(-name=>'lsubmit', -value=>'Send Last Name');

	return $field;
}
#################################################
#						#
#	Return info about National Cat Day	#
#						#
#################################################
sub CatDay {
	my $page = 
		p("Have you heard about National Cat Day 2014 on October 29th?",
		a({-href=>'index.pl?look=cat&first='.$_[0].'&last='.$_[1]}, qq(Look all images of cats )), 
			qq(this script can find in my special beast's collection.)) .
	div( { -class=>'box'}, img{src=>'img/kitten.jpg', alt=>'Cat'} ) . 
	div( { -class=>'box'}, img{src=>'img/smallcat.jpg', alt=>'cat'}) .
	p(
	a({-href=>"http://www.nationalcatday.com/", -target=>'_new'},qq(Check it out)), qq(on official National Cat Day webpage)
	);
	return $page;
}

sub LookPic {
	my $link;
	my $pics = $_[0];
	$pics =~ /cat/i and $pics = 'cat|kitten' and
       		$link =	p(qq(Hate cats? - ), a({-href=>'index.pl?look=dog'},qq(look at dogs.)));
	$pics =~ /dog/i and $pics = 'dog|pug|pup' and
		$link =	p(qq(Hate dogs? - ), a({-href=>'index.pl?look=cat'},qq(look at cats.)));
	my $page =
	p(qq(I hope these beasts would bright your day and make you a little bit nicer)).
	$link;

	while(< img/*.* >){

		if( /$pics/i ){
		$page .= div( { -class=>'box'}, img{src=>$_, alt=>$pics} ); 
		}
	}
	
	$page .= p(
	a({-href=>"http://www.nationalcatday.com/", -target=>'_new'},"Check it out"), qq(on official National Cat Day webpage)
	);
	return $page;
}

sub openDB {

	$dbh = DBI->connect('DBI:mysql:kubrakk', "kubrakk", '1186601');
	return $dbh;


}
sub addRow {
	my $space = '';
	my($dbh, $fname, $lname, $miles, $cats, $dogs, $brand) = @_;
	my $indbh = $dbh->prepare_cached('INSERT INTO classmates VALUES(?,?,?,?,?,?,?)');
	$indbh->execute('', $fname, $lname, $miles, $cats, $dogs, $brand);
}

1;
