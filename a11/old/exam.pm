sub menu {
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


	for my $key(sort keys %menu){
		$list .=  li( a({-href=>$menu{$key}[1]}, $menu{$key}[0])) 
		};
	return $list;

}

#################################################
# 		print top of the page		#
# ###############################################
sub top {
        my $title =  $_[0];
        my $header = $_[1];
        my $subheader = $_[2];
	$jscript = &ValidationFormScript if ($_[3] eq 'script');
	$jscript = &ValidationNewUserScript if ($_[3] eq 'new_user');


	############################
	#       PAGE STARTS HERE   #
	############################
print 	header(-cookie => $_[4]); 
print	start_html(
		-title=>$title,
		-head=>[Link({-rel=>'stylesheet',
				-href=>'../css/base.css'}),
			Link({-rel=>'stylesheet',
				-href=>'http://fonts.googleapis.com/css?family=Lobster&subset=latin,cyrillic'}),
			Link({-rel=>'stylesheet',
				-href=>'http://fonts.googleapis.com/css?family=Source+Sans+Pro:300,900,900italic'}),
			Link({-rel=>'stylesheet',
				-href=>'http://fonts.googleapis.com/css?family=Source+Sans+Pro:900&effect=anaglyph|fire-animation'}),
			$jscript
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
			&menu #print menu stored in sub &list
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
	textfield(-name=>'fname', 
		-size=>20, -value=>$_[0], -placeholder=>'First Name', -maxlength=>40);
	return $field;
}

sub LastNameField {
	my $field =
	"Last Name: " .
	hidden('first', $first) .
	textfield(-name=>'lname', 
		-size=>20, 
		-value=>$_[0], 
		-placeholder=>'Last Name', 
		-maxlength=>40
	);

	return $field;
}

sub PasswordField {
	if($_[0] == 2) {
		my $second =
		password_field( -name=>'secret2',
			-size=>50,
			-maxlenght=>50) .
		br()
	}
	my $field = 
		"Create password: " .
		br() .
		password_field( -name=>'secret1',
			-size=>50,
			-maxlenght=>50).
		br() .
		$second 

	return $field;
}

sub NewStudentForm {
	my $form = 
	start_form( -method=>'post', -action=>'') .
		&FirstNameField($_[0]) .
		&LastNameField($_[1]) .
		&PasswordField(2) .
	submit(-name=>'create', -value=>'New Student').
	end_form
	);
	return $form;
}




#################################################
#						#
#	Return info about National Cat Day	#
#						#
#################################################



sub addRow {
	my $space = '';
	my($dbh, $fname, $lname, $miles, $cats, $dogs, $brand) = @_;
	my $indbh = $dbh->prepare_cached('INSERT INTO classmates VALUES(?,?,?,?,?,?,?)');
	$indbh->execute('', $fname, $lname, $miles, $cats, $dogs, $brand);
}
sub deleteRow {

	 $delQuerry = $dbh->do(qq(DELETE from classmates WHERE id='$_[0]'));
	 return $_[0];
 
	
}

sub studentForm {

	@petsValues = (0,1,2,3,4,5,6);
	$radioCats = 
	
		radio_group(-name=>'cats',
			-values=>\@petsValues,
			-default=>$_[4],
			-linebreak=>'true'
		);
	$radioDogs = 
		radio_group(-name=>'dogs',
			-values=>\@petsValues,
			-default=>$_[5],
			-linebreak=>'true'
		);
	@brand = ('', "Lenovo", "HP", "Samsung",  "MAC");
	%brandValues = (
			'' => 'Pick a Brand',
			"Lenovo" => 'Lenovo',
			"HP" => "HP",
			"Samsung" => "Samsung",
			"MAC" => "Mac"
		);
	$checkBrand = 
		popup_menu(
			-name=>'brand',
			-values=>\@brand,
			-default=>$_[6],
			-labels=>\%brandValues,
		);
	$hiddenField = hidden('id', $_[0]);
	$submitButton = q(<input type="submit" value="Submit" name="add">);
	if($_[0] =~ /\d+/) {
		$submitButton = submit(-name=>'update', -value=>'Update Classmate');
	}
		
	my $addForm = qq(
	<form method="post" action="" name="arc" onsubmit="return FormValidator(this)" >
	$hiddenField
	First name:<br>
	<div class="alert" id="fn">
	</div>
	<input type="text" name="fname" value='$_[1]'><br>
	Last name:<br>
	<div class="alert" id="ln">
		</div>
	<input type="text" name="lname" value='$_[2]'><br>
	The distantce from your home to ARC in miles:<br>
	<div class="alert" id="ms"></div>
	<input type="text" name="miles" value='$_[3]'><br>
	How many cats do you have:<br>
	<div class="alert" id="cs"></div>
	$radioCats
	
	How many dogs do you have:<br>
	<div class="alert" id="ds"></div>
	$radioDogs
	Which brand of computer you own:<br>
	<div class="alert" id="bd"></div>
	$checkBrand
	<br>
	$submitButton
	</form>

	);
	return $addForm;
}

sub ValidationFormScript {
	$jscript = q(
	
	 <script>
// reg.expr. for first name - only letters;
nameRE = /^[A-Z]+[a-zA-Z]*$/;
// reg.exp for a last name - apostrophis or dashes might be in
lnameRE = /^[a-zA-Z]+[.'-]*[a-zA-Z]+$/;
// integers or floats with no more than 3 digit before and 
// just 1 digit after decimal point
milesRE = /^(?:\d{1,3}|\d{1,3}\.\d)$/;
function FormValidator()
 {
	var isFName = nameRE.test(arc.fname.value); //check first name
	var isLName = lnameRE.test(arc.lname.value); //check last name
	var isMiles = milesRE.test(arc.miles.value); //check distance
	var cnum = -1; 
	// loop to check if any number of cats selected
	for (i = 0; i < arc.cats.length; i++) {
		if(arc.cats[i].checked)
		{
			cnum = i;
		}
	}
	// loop for dogs
	var dnum = -1;
	for(i=0; i<arc.dogs.length; i++)
	{
		if(arc.dogs[i].checked)
		{
			dnum = i;
		}
	}

	// validation for the computer brand

	var brandCheck = false;
	var brandIndex = arc.brand.selectedIndex;
	if (arc.brand.options[brandIndex].value !== "") {
		brandCheck = true;
	}
	

// if statements expose the  invalid answers
		if(!isFName ){
			
			document.getElementById("fn").innerHTML  = "Only letters, starting with a capital letter";
			
		}
		else document.getElementById("fn").innerHTML  = "OK";
		
		if(!isLName){
			document.getElementById("ln").innerHTML = "Please enter a valid name - letters, a dash and apostrophie only";
			
		}
		else document.getElementById("ln").innerHTML = "OK";
		
		if(!isMiles){
			document.getElementById("ms").innerHTML = "A whole number from 0 to 999 or a decimal with one digit after the decimal point. ";
			
		}
		else document.getElementById("ms").innerHTML = "OK";
		
		if(cnum == -1)
		{
			document.getElementById("cs").innerHTML = "Please pick a number";
		}
		else document.getElementById("cs").innerHTML = "OK";
		
		if(dnum == -1)
		{
			document.getElementById("ds").innerHTML = "Please pick a number";

		}
		else document.getElementById("ds").innerHTML = "OK";
		
		if (!brandCheck) {
			document.getElementById("bd").innerHTML = "Please choose a brand";
			}
		else document.getElementById("bd").innerHTML = "OK";

		// if validation fails - return false
		if (!isFName || !isLName || !isMiles || cnum == -1 || dnum == -1 || !brandCheck){
		return false;
		}

	return true;
}


	

	</script>
	);
	return $jscript;
}

1;
