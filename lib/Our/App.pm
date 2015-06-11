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

#get '/greet/:name/job/:position' => sub {
#param('name');

get '/greet/:name' => sub {
    my $name = param('name');
    template 'greet_person' => {persons_name => $name };
};

true;
