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
	$jscript = &{$_[3]};

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
       br.
	div({-class=>'alert', -id=>'fn'}, undef) .       
	textfield(
		-name=>'fname', 
		-size=>20, 
		-value=>$_[0], 
		-placeholder=>'First Name', 
		-maxlength=>40) .
	br;
	return $field;
}

sub LastNameField {
	my $field =
	"Last Name: " .
	br .
	div({-class=>"alert", -id=>'ln'}, undef) .
	textfield(-name=>'lname', 
		-size=>20, 
		-value=>$_[0], 
		-placeholder=>'Last Name', 
		-maxlength=>40
		) .
		br;

	return $field;
}

sub PasswordField {
	my $n = @_;
	my $double;
	if($n == 2){
		 $double = 
		"Repeat password: " .
		br .
		div({-class=>'alert', -id=>$_[1]},undef ) .
		password_field( 
				-name=>$_[1],
				-size=>20,
				-maxlenght=>50
			) .
		br;
	}
	my $field = 
		"Enter password: " .
		div({-class=>'alert', -id=>$_[0]}, undef) .
		password_field( -name=>$_[0],
			-size=>20,
			-maxlenght=>50).
		br . $double;

	return $field;
}

sub NewStudentForm {
	my $form = 
	start_form( 
		-method=>'post', 
		-name=>'enrollForm', 
		-action=>"",  
		-onsubmit=>'return ValidateEnrollForm(this)') .
		&FirstNameField($_[0]) .
		&LastNameField($_[1]) .
		&PasswordField($_[2], $_[3]) .
	submit(-name=>'enroll', -value=>'Enroll').
	end_form;
	
	return $form;
}


sub openDB {

	$dbh = DBI->connect('DBI:mysql:kubrakk', "kubrakk", '1186601');
	return $dbh;


}

sub GetExamResults {
	$q = $dbh->prepare('SELECT  
				country, org, origin, folios, page,year,century, author
			FROM answers 
			WHERE sid = ? '
			)
			or die  "Couldn't prepare statement: " . $dbh->errstr;

			$q->execute($_[0])
				or die "Couldn't execute statement: " . $dbh->errstr;
			while(@rows = $q->fetchrow_array()){
				return @rows;
			}
	}


sub StartForm {

	my $form = 
		start_form(-name=>'', -action=>'index.pl', -method=>'post') .

		submit(-name=>'newStudent', -value=>'New Student') .
		end_form .
		br .
		start_form( -name=>'loginform', -method=>'post', -action=>'', -onsubmit=>'return ValidateLoginForm(this)') .
			&FirstNameField($_[0]) .
			&LastNameField($_[1]) .
			&PasswordField('secret') .
		submit(-name=>'log_in', -value=>'Login') .
	
		end_form;
	return $form;
}

sub ExamForm {
	if(@_ == 0){
		$_[5] = $_[6] = "-";
	}
	my @yearValues = qw(1960 1915 1952 2001 1867 1951 1979);
	my @centuryValues = qw(5 17 12 9 4 1 2);
	my %centuryLabels = (
		"5"	=>	'Early 5th',
		"17"	=>	'Late 17th',
		"12"	=>	'Mid 12th',
		"9"	=>	'Early 9th',
		"4"	=>	'4th',
		"1"	=>	'1st',
		"2"	=>	'2nd'
		);

		my @authorValues = ( "", "Navajo tribe", "Scotlands","Irish scholars", "Columban monks",);

		my %authorLabels = (
		""			=>	"Pick a group",
		"Navajo tribe"		=>	"Navajo tribe",
		"Scotlands"		=>	"Pictish Scotlands",
		"Irish scholars"	=>	"Irish scholars",
		"Columban monks"	=>	"Columban monks"
		) ;

	my $form = 
	start_form(-method=>'post', -action=>'', -name=>'exam', -onsubmit=>'return FormValidator(this)') .
	p({-class=>'question'}, 
		"What is the name of the country where The Book of Kells was produced?").
	div({-class=>'alert', -id=>'aa'}, undef) .
	"Name of the country: " . br .
	textfield(
		-name=>'country', 
		-size=>30, 
		-value=>$_[0], 
		-placeholder=>'What is the country?', 
		-maxlength=>40
		) . br .
	
		q(<p class="question">
			What is the institution/organization where The Book of Kells is displayed right now?
			Provide full name.
		</p>
		Name of an institution:<br>
		<div class="alert" id="bb">
		</div>
		) . br .
		textfield( -name=>"org", -size=>30, -value=>$_[1], -placeholder=>"Organization") .
	       	
		q(
		<p class="question">
			As you probably learned The Book of Kells is a copy of some texts. 
			These texts generally known as:
			
		</p>
		Name of the texts:<br>
		<div class="alert" id="cc">
		</div>
		) .
		textfield(
			-name=>"origin",
			-size=>30,
			-value=>$_[2],
			-placeholder=>"What is it?"
		) . br .
		q(
				<p class="question">
			How many folios The Book of Kells contains?
		</p>
		
		Number of all folios:<br>
		<div class="alert" id="dd">
		</div>
		) . br .
		textfield( 
			-name=>"folios",
			-size=>30,
			-value=>$_[3],
			-placeholder=>"How many?"
		). br .
		q(
		<p class="question">
			One of the monogram "Chi Rho" in The Book of Kells consumes the entire page or folio.
			What is the number of this folio?
		</p>
		Number of the folio/page :<br>
		<div class="alert" id="ee"></div>
		) . br .
		textfield(
			-name =>"page",
			-size =>30,
			-value =>$_[4],
			-placeholder =>"Which page?"
		) . br .
		q(
		<p class="question">
			When was produced the first facsimilie of The Book of Kells?
		</p>
		The year:<br>
		<div class="alert" id="ff"></div>
		) .
		radio_group(-name=>"year",
			-values=>\@yearValues,
			-default=> $_[5],
			-linebreak=>"true"
		) . br .
		q(
		<p class="question">
			Many scholars agre what The Book of Kells was probably dated by  ____ century.
		</p>
		Century:<br>
		<div class="alert" id="gg"></div>
		) . 
		radio_group(-name=>"century",
			-values=>\@centuryValues,
			-default=>$_[6],
			-labels=>\%centuryLabels,
			-linebreak=>"true"
		) .
		q(
		
		<p class="question">
			There are many dabates about then and where the  manuscript was produced.
			However, most certainly that The Book of Kells was created by
		</p>
		Name of the group of people:<br>
		<div class="alert" id="hh"></div>
		) .
		popup_menu(
			-name=>"author",
			-values=>\@authorValues,
			-default=>$_[7],
			-labels=>\%authorLabels,
		) .
		submit( -name=>"sendExam", -value=>"Submit Exam");

	return $form;
}


sub ValidateLoginFormScript {
	my $script = 
	q(
	<script>
	var fnameRE = /^[A-Z]+[a-zA-Z]*$/ ;
	// reg.exp for a last name - apostrophis or dashes might be in
	var lnameRE = /^[a-zA-Z]+[.'-]*[a-zA-Z]+$/;
	// check password
	var secretRE = /^\w\w{2,}$/ ;
	
	function ValidateLoginForm(){
		var isFname = fnameRE.test(loginform.fname.value);
		var isLname = lnameRE.test(loginform.lname.value);
		var isSecret = secretRE.test(loginform.secret.value);
		if(!isFname){
			document.getElementById('fn').innerHTML = "Letters only, starting with capital";
			
		}
		else document.getElementById('fn').innerHTML = "OK";
		if(!isLname){
			document.getElementById('ln').innerHTML = "Letters, dash, or apostrophy only";
		}
		else document.getElementById('ln').innerHTML = "OK";
		
		if(!isSecret){
			document.getElementById('secret').innerHTML = "At least 3 letters, numbers or _";
		}
		else document.getElementById('secret').innerHTML = "OK";
		
		if(!isFname || !isLname || !isSecret){
			return false;
		}
	}
	</script>
	
	);

	return $script;
}

sub ValidateEnrollFormScript {
	my $script = q(
<script>
	var fnameRE = /^[A-Z]+[a-zA-Z]*$/ ;
	// reg.exp for a last name - apostrophis or dashes might be in
	var lnameRE = /^[a-zA-Z]+[.'-]*[a-zA-Z]+$/;
	// check password
	var secretRE = /^\w{3,}$/ ;
	
	function ValidateEnrollForm(){
		var isFname = fnameRE.test(enrollForm.fname.value);
		var isLname = lnameRE.test(enrollForm.lname.value);
		var isSecret1 = secretRE.test(enrollForm.secret1.value);
		var isSecret2 = secretRE.test(enrollForm.secret2.value);
		var message1;
		var message2;
		var password = false;
		var secretValue1 = enrollForm.secret1.value;
		var secretValue2 = enrollForm.secret2.value;

		
			
		if(!isFname){
			document.getElementById('fn').innerHTML = "Letters only, starting with capital";
			
		}
		else document.getElementById('fn').innerHTML = "OK";
		if(!isLname){
			document.getElementById('ln').innerHTML = "Letters, dash, or apostrophy only";
		}
		else document.getElementById('ln').innerHTML = "OK";
		
		if(!isSecret1 ){
			message1 = " At least 3 letters, numbers or _ ";
;
			}
		else message1 =  "Value is OK ";

		if(!isSecret2){
			message2 =  " At least 3 letters, numbers or _ ";

		}
		else message2 = "Value is OK "	
		
			
		if(secretValue1 == secretValue2 && secretValue1 != ''){
					password = true;
					document.getElementById('secret1').innerHTML = "OK"
					document.getElementById('secret2').innerHTML = "OK";	
				
		}
		else {
			message1 +=  " Passwords doesn't match ";
			message2 +=  " Passwords doesn't match ";
			document.getElementById('secret1').innerHTML = message1;
			document.getElementById('secret2').innerHTML = message2;				
		}
	
		
		if(!isFname || !isLname || !isSecret1 || !isSecret2 || !password){
			return false;
		}
	}
</script>

);
	return $script;
}

sub ValidateExamFormScript {
	my $script = 
	q(
	

	 <script>
// reg.expr. for first name - only letters;
wordRE = /^[A-Z]+[a-zA-Z]*$/;
// reg.exp for a last name - apostrophis or dashes might be in
wordsRE = /^[a-zA-Z]+[ .'-]*[a-zA-Z]+[a-zA-Z]+[ .'-]*$/;
// just  digits 
numRE = /^\d+$/;

function FormValidator()
 {
	var isCountry = wordRE.test(exam.country.value); //check country
	var isOrg = wordsRE.test(exam.org.value); //check organization
	var isOrigin = wordRE.test(exam.origin.value); //check name of the original texts
	var isNumber = numRE.test(exam.folios.value); //check number of folios
	var isPage = numRE.test(exam.page.value); //check number of the folio
	var cnum = -1;
	var dnum = -1;
	// loop to check if any number of year selected
	for (i = 0; i < exam.year.length; i++) {
		if(exam.year[i].checked)
		{
			cnum = i;
		}
	}

	
	// loop for century

	for(i=0; i<exam.century.length; i++)
	{
		if(exam.century[i].checked)
		{
			dnum = i;
		}
	}

		// validation for the creators

	var authorCheck = false;
	var authorIndex = exam.author.selectedIndex;
	if (exam.author.options[authorIndex].value !== "") {
		authorCheck = true;
	}
	
// if statements expose the  invalid answers
		if(!isCountry ){
			
			document.getElementById("aa").innerHTML  = "Only letters, starting with a capital letter";
			
		}
		else document.getElementById("aa").innerHTML  = "OK";
		
		if(!isOrg){
			document.getElementById("bb").innerHTML = "Please enter a valid name - letters, spaces and apostrophies only";
			
		}
		else document.getElementById("bb").innerHTML = "OK";
		
		if(!isNumber){
			document.getElementById("dd").innerHTML = "A whole number, digits only ";
			
		}
		else document.getElementById("dd").innerHTML = "OK";

		if(!isPage){
			document.getElementById("ee").innerHTML = "A whole number, digits only ";
			
		}
		else document.getElementById("ee").innerHTML = "OK";
		
			
		if(cnum == -1)
		{
			document.getElementById("ff").innerHTML = "Please pick a year";
		}
		else document.getElementById("ff").innerHTML = "OK";
		
		if(dnum == -1)
		{
			document.getElementById("gg").innerHTML = "Please pick a century";

		}
		else document.getElementById("gg").innerHTML = "OK";
		
		if (!authorCheck) {
			document.getElementById("hh").innerHTML = "Please choose a name of the group";
			}
		else document.getElementById("hh").innerHTML = "OK";


		// if validation fails - return false
		if (!isCountry ||!isOrganization){
		return false;
		}

	return true;
}


	

	</script>
	);
	return $script;
}

sub EmptyScript {
	my $script = 
	q(
		<!--  empty script -->	
	);
	return $script;
}

sub TheStory {
	my $story =
	qq(
	<p>
	The Book of Kells is one of the finest and most famous of a group of manuscripts in what is known as the Insular style, produced from the late 6th through the early <span class='OK'> 9th centuries</span> in monasteries in <span class="OK"> Ireland </span>. 
	</p>
	<p>
	The Book of Kells (Irish: Leabhar Cheanannais) (<span class="OK">Dublin, Trinity College Library</span>, MS A. I., sometimes known as the Book of Columba) is an illuminated manuscript Gospel book in Latin, containing the <span class="OK">four Gospels</span> of the New Testament. 
	</p>
	<p>
	The manuscript today comprises <span class="OK">340 folios </span> and, since 1953, has been bound in four volumes. 
	</p>
	<p>
	In the Book of Kells, the Chi Rho monogram has grown to consume the entire page. Folio <span class="OK"> 34r </span> contains the Chi Rho monogram. Chi and rho are the first two letters of the word Christ in Greek.
	</p>
	<p>	
	<span class="OK">In 1951</span>, the Swiss publisher Urs Graf Verlag Bern produced the first facsimile of the Book of Kells.The majority of the pages were reproduced in black-and-white photographs, but the edition also featured forty-eight colour reproductions, including all of the full-page decorations.
	</p>
	<p>
       Regardless of which theory is true, it is certain that the Book of Kells was produced by <span class="OK">Columban monks</span> closely associated with the community at Iona.
       </p>
       );
	return $story;
}
1;
