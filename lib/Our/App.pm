package Our::App;
use Dancer2;

our $VERSION = '0.1';

set auto_page => 1;

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

#get '/new_game' =>  sub {
    #$bs->new_game( param('name') );
    #redirect '/games';
#};

any ['get','post'] => '/new_game' =>  sub {
    $bs->new_game( param('name') );
    redirect '/games';
};

get '/login' => sub {
    template 'login_template'
};

post '/login' => sub {
    my $player = $bs->new_player( param('player_name') );
    session user=>$player;
    redirect '/games';
};

get '/logout' => sub {
    #my $session = session;
    session user=>undef;
    session game_id => undef;
    # this works, but no one knows what it's doing $session->delete;#('user');
    redirect '/games';
};

get '/join/:game_id' => sub {
    my $game_id = param('game_id');
    my $player = session('user');

    # NOTE:  we need to leave any game we might be in
    # now, or they will not decrement the count...or
    # come out of the structure at all, maybe  -- Gary
    if (my $existing_game_id = session('game_id')) {
        $bs->leave_game( $existing_game_id, $player );
    }

    $bs->join_game( $game_id, $player );
    session game_id => $game_id;
    redirect '/games';
};

get '/leave/:game_id' => sub {
    my $game_id = param('game_id');
    my $player = session('user');
    $bs->leave_game( $game_id, $player );
    session game_id => undef;
    redirect '/games';
};

get '/game/:game_id' => sub {
    my $game_id = param('game_id');

    my $game_object = $bs->get_game($game_id);

    template 'view_one_game'=>{game_template_var => $game_object};
};

# this is defined on this url just because it makes it easy for the
# "ask a new question" form to be on the game page.  It should
# really be something like "/game/:game_id/ask" or something
# like that.

post '/game/:game_id' => sub {
    my $game_id = session('game_id');
    my $question = param('question');
    $bs->ask_question( $game_id, $question );
    redirect '/game/'.$game_id;
};

get '/question/:question_id/answer/:answer' => sub {
    my $game_id = session 'game_id';
    my $question_id = param 'question_id';
    my $answer = param 'answer';
    $bs->answer_question($game_id, $question_id, $answer);
    debug(" here: ($game_id, $question_id, $answer);");
    redirect '/game/'.$game_id;
};

true;
