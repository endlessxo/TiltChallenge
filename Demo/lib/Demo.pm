package Demo;
use Dancer2;
use Template;
use Net::Twitter;
use Data::Dumper;

our $VERSION = '0.1';

get '/' => sub {
    template 'home.tt', {
    'getstatus' => uri_for('/showstatus'),
    'getfollows' => uri_for('/showfollowers'),
};
};


sub twitterauth {
	my $accesstoken = $_[0];
	my $accesstokensecret = $_[1];
	my $consumerkey = $_[2];
	my $consumersecret = $_[3];

	my $nt = Net::Twitter->new(
		traits => [qw/API::RESTv1_1/],
		consumer_key => $consumerkey,
		consumer_secret => $consumersecret,
		access_token => $accesstoken,
		access_token_secret => $accesstokensecret,
	);
	return $nt;
}

sub display_recent_tweets {
	my $token = $_[0];
	my $username = $_[1];
	my @tweets = ();
	my $foo = $token->user_timeline({screen_name => [$username]});
	
	for my $foobar ( @$foo ) {
		push (@tweets, $foobar->{text});
	}
	return \@tweets;
};

sub id_conversion {
	my $token = $_[0];
	my $id = $_[1]; 
	my $username = $token->show_user({user_id => [$id]})->{'screen_name'};
	return $username;
};

sub common_follows {
	my $token = $_[0];
	my $firstperson = $_[1];
	my $secondperson = $_[2];
	my @commonfollowers = ();

	my $foo = $token->following_ids({screen_name => [$firstperson]});
	my $firstpersonfollowers = $foo->{'ids'};

	$foo = $token->following_ids({screen_name => [$secondperson]});
	my $secondpersonfollowers = $foo->{'ids'};

	for (my $foo = 0; $foo < scalar(@$secondpersonfollowers); $foo++){
		for (my $bar = 0; $bar < scalar(@$firstpersonfollowers); $bar++){
			if (@$secondpersonfollowers[$foo] == @$firstpersonfollowers[$bar]) {
				push (@commonfollowers, &id_conversion($token, @$secondpersonfollowers[$foo]));
			}
		}
	}
	return \@commonfollowers;
};

my $token = &twitterauth('a', 
	'b',
	'c',
	'd');

post '/showstatus' => sub {    
	my $username = param "user1";
        template 'show_status.tt', {
		'username' => $username,
		'recent_tweets'  => display_recent_tweets($token, $username),				
	};
};

post '/showfollowers' => sub {
	my $username1 = param "user2";
	my $username2 = param "user3";
	template 'show_follower.tt', {
		'user1' => $username1,
		'user2' => $username2,
		'common_follows' => common_follows($token, $username1, $username2),		
};
};


true;
