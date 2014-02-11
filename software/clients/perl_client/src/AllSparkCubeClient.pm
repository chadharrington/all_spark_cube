package AllSparkCubeClient;

use lib 'gen-perl';
use AllSparkCube::CubeInterface;
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
    $self->{client} = AllSparkCube::CubeInterfaceClient->new($self->{protocol});
    $self->{transport}->open();
    
    return $self;
}

sub DESTROY {
    my $self = shift;
    $self->{transport}->close();
}

sub set_colors {
    my ($self, $data) = @_;
    if (scalar $data != 4096) {
        die "Error: Length of data must be 4096. Stopped";
    }
    $self->{client}->set_data($data);
}

1;
