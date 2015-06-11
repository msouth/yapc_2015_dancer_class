package Our::App;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/user/:name' => sub {
    my $input_user = param('name');
    my $test = param('test');
    return "Hi, $input_user, you passed [$test]";
};

post '/user' => sub {
    my $input_user = param('name');
    open (my $list , '>>', '/tmp/users') or die "no luck on /tmp/users: $!";
    print $list $input_user, "\n";
    close $list;
    return "I saved $input_user";
};

any ['get','post'] => '/either' => sub {
    return request->method. "\n";
};

get '/list_things/**' => sub {
    #my @stuff = splat();

    #my $output = '';
    #BAD my $stuff = @{ splat };
    my @stuff = splat();
#    my $all_stuff 
#    foreach my $item (@$stuff) {
#        $output.="$item\n";
#    }
    use Data::Dumper;
    return Dumper(\@stuff);
};

#get '/greet/:name/job/:position' => sub {
#param('name');

get '/greet/:name' => sub {
    my $name = param('name');
    template 'greet_person' => {persons_name => $name };
};

=pod

my @games = (
    {
        name => 'Puerto Rico',
        status => 'open',
        players => [ 'Bob', 'Sally'],
        max_players => 5,
    },
    {
        name => 'Ticket to Ride',
        status => 'open',
        players => [ 'Billy', 'James'],
        max_players => 6,
    },
);

=cut

use BS;
my $bs = BS->new;

get '/games' => sub {
    # look in views/ for games_template.tt
    template games_template => {games_template_var=>$bs->games};
};

true;
