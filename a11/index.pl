#!/usr/bin/perl

use CGI::Pretty qw/:standard *table start_ul/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use DBI;

require 'exam.pm';

my $dbh = &openDB;
# provides info to the user
#
my $message;
my $sid;
my $session;
my $fname = param( "fname" );
my $lname = param( "lname" );
my $secret = param( "secret");
my $secret1 = param( "secret1" );
my $secret2 = param( "secret2" );
# get exam results
my @results =
(
 	param('country' ),
	param( 'org' ),
	param( 'origin'),
	param( 'folios'),
	param( 'page' ),
	param( 'year' ),
	param( 'century' ),
	param( 'author' )
);
	#####

my @answers = &GetExamResults('1');

my $title = "Login page";
my $greeting = "Let's check your knowledge";
my $subheader = "Please log in or enroll to start exam";

my $script = \&ValidateLoginFormScript;
my$currentForm = &StartForm($fname, $lname);

if(param('log_in')){
	if($fname =~ /^[A-Z]+[a-zA-Z]*$/){
       		if($lname =~ /^[a-zA-Z]+[.'-]*[a-zA-Z]+$/ ) {
			if($secret =~ /^\w{3,}$/){
				my $ask = $dbh->prepare('SELECT sid FROM student WHERE fname = ? AND lname = ? AND secret = ? ')
					or die "couldn't prepare statement " . $dbh->errstr;
				$ask->execute($fname, $lname, $secret)
				or die "Couldn't execute statement: " . $dbh->errstr;
					while(@data = $ask->fetchrow_array()){
						$sid = $data[0];					
					}
						if($sid =~ /^\d+$/){
							$ask = $dbh->prepare('SELECT id, time FROM answers WHERE sid = ?')
								or die  "Couldn't prepare statement: " . $dbh->errstr;
							$ask->execute($sid);
							if($ask->rows != 0){
								$currentForm =
								start_form( -name=>"goToExam", -action=>'', -method=>'post') .
								submit( -name=>"exam", -value=>'Check Your Score').
								end_form;
								$greeting = "Welcome $fname $lname!";
								$subheader = q(Let's check your knowledge);
							}
							else
							{							
								my $timestamp = time();
								my $q = $dbh->prepare('INSERT INTO cookie VALUES(?,?)')
								or die  "Couldn't prepare statement: " . $dbh->errstr;
								$q->execute($timestamp, $sid)
								or die  "Couldn't prepare statement: " . $dbh->errstr;
								#create cookie hash with exam data
								%exam = ( 
								sid => $sid,
								timestamp => $timestamp,
								fname => $fname,
								lname => $lname
								);

								$session = cookie( 
									-name=>'examID',
									-value=>\%exam
									);
								$title = "Start Exam";
								$greeting = "Welcome $fname $lname!";
								$subheader = q(Let's check your knowledge);
								$message = h2("Are you ready?") .
								p(q(It's time to take exam! Please click the button to start exam));
								$currentForm =
								start_form( -name=>"goToExam", -action=>'', -method=>'post') .
								submit( -name=>"exam", -value=>'Start Exam').
								end_form;
							}
						}
						else
						{
							$title = "Login page";
							$greeting = "Something went wrong";
							$subheader = "Unsucessful login";
							$message = "Wrong password or/and names";
							$currentForm = &StartForm($fname, $lname); 
						}
				}
				else {
					$title = "Login page";
					$greeting = "Something went wrong";
					$subheader = "Unsucessful login";
					$message = "Check password - at least 3 letters, digits, underscore ";
					$currentForm =  &StartForm($fname, $lname); 
				}
			}
			else {
				$title = "Login page";
				$greeting = "Something went wrong";
				$subheader = "Unsucessful login";
				$message = "Check last name - at   letters, dash and apostrophy ";
				$currentForm = &StartForm($fname, $lname); 
				}
		}
		else {
			$title = "Login page";
			$greeting = "Something went wrong";
			$subheader = "Unsucessful login";
			$message = "Check first name - only letters, beginning with capital letter ";
			$currentForm = &StartForm($fname, $lname); 
		}
	
}
if(param('newStudent')){
	$title = "Enrolling new user";
	$greeting = "Welcome Exam Taker";
	$subheader = "Please enter your first and last name and create a new password";
	$currentForm = &NewStudentForm(undef,undef,'secret1','secret2');
	$script = \&ValidateEnrollFormScript;

}

if(param( 'enroll' )) {
	$title = "Enrollment page";
	$greeting = "Enrollment in process";
	$subheader = "";
	$script = \&ValidateEnrollFormScript;
	

	if($fname =~ /^[A-Z]+[a-zA-Z]*$/){
       		if($lname =~/^[a-zA-Z]+[.'-]*[a-zA-Z]+$/ ) {
			if($secret1 =~ /^\w{3,}$/ and $secret1 eq $secret2) {

				my $check = $dbh->prepare('SELECT fname lname FROM student WHERE fname = ? and lname = ?');
				$check->execute($fname, $lname);
				if($check->rows == 0){
						
					
						my $add = $dbh->prepare('INSERT INTO student VALUES(?,?,?,?)');
						$add->execute('', $fname, $lname, $secret1);
						my $q = $dbh->prepare('SELECT sid 
								FROM student 
								WHERE fname = ? and lname = ?')
									or die  "Couldn't prepare statement: " . $dbh->errstr;
						$q->execute($fname, $lname)
							or die  "Couldn't execute statement: " . $dbh->errstr;
						while(@row = $q->fetchrow_array()){
							$sid = $row[0];
						}
						if($sid =~ /\d+/){
							my $timestamp = time();

							$q = $dbh->prepare('INSERT INTO cookie VALUES(?,?)')
								or die  "Couldn't prepare statement: " . $dbh->errstr;
							$q->execute($timestamp, $sid)
								or die  "Couldn't execute statement: " . $dbh->errstr;
							%exam = ( 
								sid => $sid,
								timestamp => $timestamp,
								fname => $fname,
								lname => $lname
							);

							$session = cookie( 
									-name=>'examID',
									-value=>\%exam
									);
							$title = "Enrollment finished";
							$greeting = "Welcome $fname $lname!";
							$subheader = "Your accaunt has been created!";
							$message = h2("Are you ready?") .
							p("It's time to take exam! Please click the button to start exam");
							$currentForm =
							start_form( -name=>"goToExam", -action=>'', -method=>'post') .
							submit( -name=>"exam", -value=>'Start Exam').
							end_form;
						}
						else {
							$subheader = "Something went wrong";
							$message = p(" database troubles.
					       				Try again later");
							$currentForm = &NewStudentForm($fname, $lname, 'secret1', 'secret2');
						}
											
					}
					else {
						$subheader = "Something went wrong";
						$message = p("$fname $lname is already in the database.
					       			Please enter unique name");
						$currentForm = &NewStudentForm($fname, $lname, 'secret1', 'secret2');
					}
			}
			else {
			
				$subheader = "Something went wrong";
				$message = "Please enter the same password into two fields";
				$currentForm = &NewStudentForm($fname, $lname, 'secret1', 'secret2');
			}

		}
		else {
			$subheader = "Something went wrong";
			$message = "Please check your last name. Only letters, dash or apostrophy";
			$currentForm = &NewStudentForm($fname, $lname, 'secret1', 'secret2');
		}
	}
	else {
		$subheader = "Something went wrong";
		$message = "Please check your first name. Only letters, dash or apostrophy";
		$currentForm = &NewStudentForm($fname, $lname, 'secret1', 'secret2');
	}

}	
if(param( 'exam' )){
	if( cookie('examID') ){
		my %student = cookie('examID');
		$sid = $student{sid};
		my ($time) =  $student{timestamp}  ;
		my $q = $dbh->prepare('SELECT time FROM cookie WHERE sid = ?');
		$fname = $student{fname};
		$lname = $student{lname};


		$q->execute($sid);
		while(my @row = $q->fetchrow_array()){
			$stamp = $row[0];
		}

		if($time == $stamp  && $time =~ /^\d{10}$/ ){

			$q = $dbh->prepare('SELECT 	grade, time, country, 
							org, origin, folios, 
							page,year,century, author
						FROM 
							answers 
						WHERE sid = ? '
					)
						or die  "Couldn't prepare statement: " . $dbh->errstr;

			$q->execute($sid)
				or die "Couldn't execute statement: " . $dbh->errstr;
	
			if($q->rows == 0){
				$currentForm = &ExamForm;
				$script = \&ValidateExamFormScript;
				$greeting = "What do you know about The Book of Kells";

			}
			else
			{	
					while(@rows = $q->fetchrow_array()){
					#  0    1    2     3     4    5     6     7     8
    					($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =  localtime( $rows[1] );
					$year += 1900;
					my @abbr = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
					
					$rows[1] = "$mon / $mday / $year at $hour:$min";
					unshift @answers, 'Grade', 'Time';
					$trow .= 
						Tr([
							th(\@answers),
							td(\@rows)
						]);
					}


				my @header = qw( Grade Time 1 2 3 4 5 6 7 8);
				 $table = 
					start_table({-border=>1}) .
					
					$trow .
					end_table;
				
				shift @answers;
				shift @answers;
				my $text = &TheStory;
				$currentForm = $table . p($text);
				$message = "The exam has been already taken by you. Check your answers and grades";
				$title = "Exam Result page";
				$greeting = "Amazing Results";
				$subheader = "It's never too late to learn something knew";

			}


		
		}
		else {
			$currentForm = &StartForm($fname, $lname);
			$message = "Something went wrong. Please enable cookie and login again";
		}
	}
	else {
		$currentForm = &StartForm($fname, $lname);
		$message = "Something went wrong. Please enable cookie and login again";
	}

}

if(param('sendExam')){
	if( cookie('examID') ){
		my %student = cookie('examID');
		$sid = $student{sid};
		my ($time) =  $student{timestamp}  ;
		my $q = $dbh->prepare('SELECT time FROM cookie WHERE sid = ?');
		$fname = $student{fname};
		$lname = $student{lname};

		$q->execute($sid);
		while(my @row = $q->fetchrow_array()){
			$stamp = $row[0];
		}
		

	
		#
		#
		$i = 0; $r=0; $w=0;
		for $check (@results){
			if($answers[$i] =~ /$check/i){
				$r++;
				$studentRow[$i]= span({-class=>'OK'}, $check);
			}
			else {
				$w++;
				$studentRow[$i] = span({-class=>'NotOK'}, $check);
			}
			$i++;
		}
		$grade = $r/8 * 100;	

		if($time == $stamp  && $time =~ /^\d{10}$/ ){
			my $examtime = time();		##		1 2  3  4  5  6  7  8  9  10  11 12
			$q = $dbh->prepare('INSERT INTO answers VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?,  ?, ?,  ?)')
					or die  "Couldn't prepare statement: " . $dbh->errstr;
				$q->execute(
					undef, $sid, $grade, $examtime,
					$results[0],$results[1],$results[2],$results[3],
					$results[4],$results[5],$results[6],$results[7]
					) 	
						or die  "Couldn't execute statement: " . $dbh->errstr;
				$table = start_table({-border=>'1'}) .
						Tr([
							th(\@answers),
							td(\@studentRow)
						]) .
					end_table;

				$currentForm = $table . p(&TheStory);
				$message .= "\n Your grade is $grade $r $w";
				$title = "Exam Result page";
				$greeting = "Amazing Results $grade %";
				$subheader = "It's never too late to learn something knew";
		}
		else {
			$currentForm = &StartForm($fname, $lname);
			$message = "Something went wrong. Please enable cookie and login again";
		}
	}
	else{
		$currentForm = &StartForm($fname, $lname);
		$message = "Something went wrong. Please enable cookie and login again";

	}
}
	&top($title, $greeting, $subheader, $script, $session );

	print	div({ -class=>'main'},
			$message,
			$currentForm	
		),
	end_html;
