#!/usr/bin/perl

$add = $ENV{'REMOTE_ADDR'};
$browser =$ENV{'HTTP_USER_AGENT'};
$server = $ENV{'SERVER_NAME'};
$port = $ENV{'SERVER_PORT'};
print "Content-type: text/html\n\n";


my $page = << "PAGE_ENDS_HERE";
"<html>
<!DOCTYPE html>

<html>
<head>
<meta charset='UTF-8'>
	<title>Perl - Kastus Kubrak</title>
	<link rel="stylesheet" type="text/css" href="../css/base.css"/>
	<link href='http://fonts.googleapis.com/css?family=Lobster&subset=latin,cyrillic' rel='stylesheet' type='text/css'>
	<link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:300,900,900italic' rel='stylesheet' type='text/css'>
	 <link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Source+Sans+Pro:900&effect=anaglyph|fire-animation" />


		
</head>
<body>


	<div class="roller">
		<img src="../css/forange.png" alt="an orange">
	</div>
<div class="top">

	
		<div class="topbar">
			<h1>Let's try some Perl</h1>
			<h3 class="font-effect-anaglyph">It's surely fun!</h3>
		</div>
					<div class="navbar">
				<ul>
					<li>
						<a href="../a01/">JS Basics</a>
					</li>
					<li>
						<a href="../a02">Browser</a>
					</li>
					<li>
						<a href="../a03">Slideshow</a>
					</li>
					<li>
						<a href="../a04">Windows</a>
					</li>
					<li>
						<a href="../a05">Forms</a>
					</li>
					<li>
						<a href="../a06">Perl Basics</a>
					</li>
					<li>
						<a href="../a07">Param</a>
					</li>
					<li>
						<a href="../a08">Hidden</a>
					</li>
					<li>
						<a href="../a09">Sort</a>
					</li>
					<li>
						<a href="../a10">Add</a>
					</li>
					<li>
						<a href="../a11">Project</a>
					</li>
				</ul>
			</div>
		
</div>
<div class="main">

<h3>IP address: $add</h3>
<h3>Server Name: $server</h3>
<h3>Port number: $port</h3>
<h3>Your browser: $browser</h3>
</div>


	

	
</body>
</html>
PAGE_ENDS_HERE
print $page;
