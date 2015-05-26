#!/usr/bin/perl

use CGI::Pretty qw/:standard *table start_ul/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use DBI;

require '../lib/mysubs.pm';

$dbh = &openDB;
my $message;
# fetch and check parameters from form to assign to variables
# logic check 
( param('fname') ne '') and my $fname = param('fname');
( param('lname') ne '') and my $lname = param('lname');
# and if check
my $miles = param('miles')if (param('miles') =~ /^\d+/);
my $cats = param('cats') if(param('cats') =~ /^\d$/);
my $dogs = param('dogs') if(param('dogs') =~ /^\d$/);
my $brand = param('brand') if(param('brand') =~ /^\w+$/);
# variables for sorting the table
my $sort; 	# keeps the field  to sort
my $desc;	# trigge for descending order
my $trailer;	# ORDER BY part of the querry
my $up =  '&uArr;';	# arrows show of direction of sorting in header of the table
my $down = '&dArr;';
my $addForm;
my $editClassmate = submit( -name=>'delete', -value=>'Delete Checked Classmate') . submit(-name=>'edit', value=>'Edit Checked Classmate');
my $checkToDeleteClassmateButton = submit( -name=>'checkClassmate', -value=>'Edit Classmate');

my $deleteButton = $checkToDeleteClassmateButton;

my $newClassmateButton =
		start_form( -method=>'post', -action=>'') .
		submit(-name=>'enter', -value=>'New classmate').
		$deleteButton .
		end_form;

my $currentForm = $newClassmateButton;



if(param('checkClassmate')){
	$deleteButton = $editClassmate;
}


if(param('delete')){
	
	
	$id = param('editRow');
	if($id =~ /\d+/){
	&deleteRow($id);
	$message.= " $id deleted "; 
	}
}

if(param('edit')){
	
	$id= param('editRow');		
	if($id =~ /\d+/){
		$qu = $dbh->prepare('SELECT * FROM classmates WHERE id = ?');
		$qu->execute($id);

		while(@row = $qu->fetchrow_array()) {
		$currentForm = &studentForm(@row);
		}	
	
	}
		
}

if(param('update')){
	if(param('id') =~ /\d+/){            
		$id = param('id');
		$updateRow = $dbh->prepare('UPDATE classmates SET fname = ?, lname = ?, miles = ?, cats = ?, dogs = ?, brand = ?
                                   WHERE id = ?');
		$updateRow->execute($fname, $lname, $miles, $cats, $dogs, $brand, $id);
		$message  = "$fname, $lname, $miles, $cats, $dogs, $brand, $id";
	}
}

# array of the table fields 
@order = qw(id fname  lname miles cats dogs brand);
# fetch which field is clicked, and check the value
if(param('sort') =~ /id|fname|lname|miles|cats|dogs|brand/) {
	$sort = param('sort');
	# sorting logic: apply DESCENDING order to the query and applicable link or overwise
	for ($i = 0; $i<= 6; $i++ ) {
		if($order[$i] =~ /$sort/){
			if(param('desc') eq ''){
				$desc = '';
				$trig[$i] .= '&desc=desc';
				$arrow[$i] = $down;
				last;	
			}
			elsif(param('desc') eq 'desc'){
				$desc = ' DESC ';
				$trig[$i] = '';
				$arrow[$i] = $up;
				last;
			}
		}
	}
# 	
 	$trailer .= 'ORDER by '. $sort .$desc;

}
# insert data in database if submit button is clicked

if(param('enter')){
	$currentForm = &addForm;

}


if (param('add') ){
	$checkRow = $dbh->prepare('SELECT * FROM classmates WHERE fname = ? and lname = ?');
	$checkRow->execute($fname, $lname);
	if($checkRow->rows == 0){
	&addRow($dbh,$fname, $lname, $miles, $cats, $dogs, $brand);
	$message = "The info is added $fname $lname $miles $cats $dogs $brand";
	}
	else {
		$message .= "Cannot add!  $fname $lname already exist in the database. No changes is made";
		$currentForm = &studentForm(undef, $fname, $lname, $miles, $cats, $dogs, $brand);
	}
}
# querry to get data from database
	$cursor = $dbh->prepare("SELECT * FROM classmates $trailer");
	$cursor->execute;
	
# get the header of the table
my $table = start_table(); 
 	$table .= Tr(
			[
				th([	a({-href=>'index.pl?sort=' .$order[0]. $trig[0]},'ID'. $arrow[0]),
					a({-href=>'index.pl?sort=' .$order[1]. $trig[1]}, 'First Name'. $arrow[1]),
					a({-href=>'index.pl?sort=' .$order[2]. $trig[2]},'Last&nbsp;Name'. $arrow[2]), 
					a({-href=>'index.pl?sort=' .$order[3]. $trig[3]}, 'Distance' . $arrow[3]), 
					a({-href=>'index.pl?sort=' .$order[4]. $trig[4]}, 'Cats'. $arrow[4]),
					a({-href=>'index.pl?sort=' .$order[5]. $trig[5]}, 'Dogs' . $arrow[5]),
					a({-href=>'index.pl?sort=' .$order[6]. $trig[6]}, 'Brand'. $arrow[6]),
					$delStr
				])
			]
		);
my @values;
my @labels;
		#
# fetch the data and insert into the table
#
#
# <input type="radio" name="deleteRow" value="6" />
while(@row = $cursor->fetchrow_array()) {
	if(param('checkClassmate')){

	$radioGroup = radio_group(-name=>'editRow',
			-values=>$row[0],
			-labels=>\%label,
			);
	
	}	

	$table .= Tr(
		       td([ $row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6], $radioGroup
			  ])
		);




}
$table .= end_table();
# end of the table
if(param('checkClassmate')){
	
$currentForm =
		start_form( -method=>'post', -action=>'') .
		$table .
		submit(-name=>'enter', -value=>'New classmate').
		$deleteButton .
		end_form;
		$table = '';
}

# title, header, and subheader of the page
my $title = 'Show and Sort Database';
my $greeting = 'Your Classmates';
my $subheader = 'All you need to know about them';

# call &top to print top of the page with  title and greetings
&top($title, $greeting, $subheader, 'script');

print	div({ -class=>'main'},
		$table,
		$message,
		$currentForm	
	),
end_html;




