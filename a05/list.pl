#!/usr/bin/perl

use CGI::Pretty qw/:standard/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

my $message;	# keeps list of checked things
my $s;		# add plural s	
my $numb;	# number of checked things
my $list;	# menu
my $browserBox;
my $browser =$ENV{'HTTP_USER_AGENT'};

# hash keeps links of the main menu
my %menu = (
			"01"	=>	['JS Basics',	'../a01/'],
			"02"	=>	['Browser',	'../a02/'],
			"03"	=>	['Slideshow',	'../a03'], 
			"04"	=>	['Windows',	'../a04'],
			"05"	=>	['Forms',	'../a05'],
			"06"	=>	['Perl Basic',	'../a06'], 
			"07"	=>	['Param',	'../a07'],
			"08"	=>	['Hidden',	'../a08'],
			"09"	=>	['Sort',	'../a09'],
			"10"	=>	['Add',		'../a10'],
			"11"	=>	['Project',	'../a11']
	);


for my $key(sort keys %menu){$list .=  li( a({-href=>$menu{$key}[1]}, $menu{$key}[0])) };


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

if(param('things') ne '') { 
	
	@things = param('things');
	$numb = @things;
	if($numb > 1) {$s = 's'};
	for $thing(@things){
		$message .= li($thing);
	}
	$message = ul($message);
	$message =  p({ -class => $class}, $info, br, "Your list has $numb thing" . $s .":") . $message;
}




	# empty all paremeters
Delete_all();
print 	header; 
print	start_html(
		-title=>'Param Function, Arrays and Browser Detection - part 2',
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

	
print	div({-class=>'roller'},
		img({-src=>'../css/forange.png', -alt=>'an orange'})
	);
print	div({ -class=>'top'},
		div({ -class=>'topbar'},
			h1('Your shopping list'),
			h3({ -class=>'font-effect-anaglyph'}, 'Check anything you need')
		)
	);

	
print	div({ -class=>'navbar'},
		ul(
			$list #print menu stored in the variable $list
		)
	);
		
print	div({ -class=>'main'},
	div({ -class => $class}, $message),
	start_form( -method=>'post', -action=>''),
	checkbox_group(-name=>'things', -values=>
			[	
			'lamp',
			'car', 
			'book', 
			'chair', 
			'desk', 
			'hat',
			'bike',
			'picture',
			'table'
			]
		),	
	submit(-name=>'submit', -value=>'submit'),
	

	end_form
	),
	end_html;




