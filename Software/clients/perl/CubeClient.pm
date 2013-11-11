package CubeClient;

use lib 'gen-perl';
use cube::CubeInterface;
use Thrift::Socket;
use Thrift::BufferedTransport;
use Thrift::BinaryProtocol;


sub new {
    my $class = shift;
    my ($host, $port) = @_;
    my $self = bless {
        host => $host,
        port => $port,
    }, $class;
    
    $self->{socket} = Thrift::Socket->new($self->{'host'}, $self->{'port'});
    $self->{transport} = Thrift::BufferedTransport->new($self->{socket});
    $self->{protocol} = Thrift::BinaryProtocol->new($self->{transport});
    $self->{client} = cube::CubeInterfaceClient->new($self->{protocol});
    $self->{transport}->open();
    
    return $self;
}

sub DESTROY {
    my $self = shift;
    
    $self->{transport}->close();
}

sub set_data {
    my $self = shift;
    my ($index, $data) = @_;
 
   $self->{client}->set_data($index, $data);
}

1;
