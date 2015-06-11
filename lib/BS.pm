package BS;
use strict;
use warnings;
use List::Util qw<first shuffle>;

my %stories = (
    'Two Dead Men' => {
        description => 'Two dead men are seated at a table. On the table between them is a game of chess and a pistol.',
        full_text   => 'The two men were in a submarine stranded on the ocean floor. There was enough air for only a few hours. There was only one bullet in the gun so they played chess to see who would be allowed to shoot himself and who would have to suffocate',
    },

    'The Murdered Mayor' => {
        description => 'A priest of giving a farewell speech. Towards the end of the speech, the mayor arrives to add a word of thanks, but is shot dead before he finishes speaking.',
        full_text   => q{In his speech, the priest remembered the peculiar murder that had occurred on his first day in the parish, and said that the very first confession he heard that day was from the murderer. The mayor had missed the first part of the speech and he reported that he was the first to enter the new priest's confessional. The mayor, having thus betrayed himself, was shot dead by a relative of the murder victim.},
    },

    'The Naked Man' => {
        description => 'A stark naked man was found dead at the foot of a mountain - with a matchstick in his hand',
        full_text   => q{A hot-air balloon carrying four passengers had gone off course and threatened to smash into a mountain. To gain height, the passengers threw all the ballast, including their clothing, overboard. It wasn't enough: one of them would have to jump. They drew lots - and the dead man drew the shortest match},
    },
);

sub _get_random_story {
    return delete $stories{ ( keys %stories )[0] };
}

my $game_id     = 1;
my $question_id = 1;

sub new { bless {}, 'BS' }

sub games {
    my $self = shift;
    return [ values %{ $self->{'games'} } ];
}

sub get_game {
    my ( $self, $id ) = @_;
    return $self->{'games'}{$id};
}

sub new_game {
    my ( $self, $name ) = @_;
    my $id   = $game_id++;
    my $game = {
        id          => $id,
        name        => $name || 'Anonymous game',
        status      => 'open',
        players     => {},
        num_players => 0,
        max_players => 2,
    };

    $self->{'games'}{$id} = $game;
    return $game;
}

sub new_player {
    my ( $self, $name ) = @_;
    $name or die "Must provide name\n";
    return { username => $name };
}

sub join_game {
    my ( $self, $game_id, $player ) = @_;
    my $game = $self->{'games'}{$game_id};

    $game->{'num_players'} == $game->{'max_players'}
        and return;

    $game->{'players'}{ $player->{'username'} } = $player;
    $game->{'num_players'}++;

    if ( $game->{'num_players'} == $game->{'max_players'} ) {
        $game->{'status'} = 'running';
        $game->{'story'}  = _get_random_story(),
        _assign_players($game);
    }

    return 1;
}

sub _assign_players {
    my $game    = shift;
    my $players = $game->{'players'};

    my $story_teller = ( keys %{$players} )[0];

    foreach my $player ( keys %{$players} ) {
        $players->{$player}{'role'} = $player eq $story_teller
                                    ? 'story_teller'
                                    : 'player';
    }
}

sub leave_game {
    my ( $self, $game_id, $player ) = @_;
    delete $self->{'games'}{$game_id}{'players'}{ $player->{'username'} };
    $self->{'games'}{$game_id}{'num_players'}--;
}

sub ask_question {
    my ( $self, $game_id, $question ) = @_;
    push @{ $self->{'games'}{$game_id}{'questions'} }, {
        id       => $question_id++,
        question => $question, # answer => ...
    };
}

sub answer_question {
    my ( $self, $game_id, $question_id, $answer ) = @_;
    my ($question) = grep +( $_->{'id'} == $question_id ),
        @{ $self->{'games'}{$game_id}{'questions'} };

    $question->{'answer'} = $answer;

    if ( $answer eq 'Win' ) {
        $self->{'games'}{$game_id}{'status'} = 'closed';
    }
}

1;
