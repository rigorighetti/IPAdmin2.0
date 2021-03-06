package IPAdmin;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Authentication
    Authorization::Roles
    Authorization::ACL
    Scheduler
    Session
    Session::Store::DBI
    Session::State::Cookie
    StackTrace
    Authentication::Credential::Password
/;

extends 'Catalyst';

our $VERSION = '0.01';
# Configure the application.
#
# Note that settings in ipadmin.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

our $NEW       = 0;
our $PREACTIVE = 1;
our $ACTIVE    = 2;
our $INACTIVE  = 3;
our $ARCHIVED  = 4;
#our $DELETED   = 4;

__PACKAGE__->config(
    name         => 'IPAdmin',
    default_view => 'TT',
    use_request_uri_for_path => 1,

    enable_catalyst_header => 1, # Send X-Catalyst header

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    authentication  => {
        default_realm => 'normal_then_ldap',
        realms        => {
           'normal_then_ldap' => {
		class  => 'Progressive',
                realms => [ 'normal', 'ldap' ],
            },
            'normal' => {
                credential => {
                    class              => 'Password',
                    password_field     => 'password',
                    password_type      => 'hashed',
                    password_hash_type => 'MD5'
                },
                store => {
                    class         => 'DBIx::Class',
                    user_model    => 'IPAdminDB::User',
                    role_relation => 'roles',
                    role_field    => 'role',
                }
             },
            'ldap' => {
                credential => {
                  class => "Password",
                  username_field => "username",
                  password_field => "password",
                  password_type  => "self_check",
                },
                store => {
                  binddn              => "anonymous",
                  bindpw              => "",
                  class               => "LDAP",
                  ldap_server         => "mail.uniroma1.it",
                  ldap_server_options => { timeout => 100 , onerror => "warn"},
                  role_basedn         => "", #This should be the basedn where the LDAP Objects representing your roles are.
                  role_field          => "",
                  role_filter         => "",
                  role_scope          => "one",
                  role_search_options => { deref => "always" },
                  role_value          => "dn",
                  role_search_as_user => 0, #role disabled
                  start_tls           => 0, #disabled
                  start_tls_options   => { verify => "none" },
                  entry_class         => "Net::LDAP::Entry",
                  use_roles           => 0,
                  user_basedn         => "o=uniroma1,c=it",
                  user_field          => "cn",
                  user_filter         => "(&(objectClass=person)(cn=%s))",
                  user_scope          => "sub", # 
                  user_search_options => { deref => "always" },
                  user_results_filter => sub { return shift->pop_entry },
                },
              },
           }, #realms
     },  #plugin::auth
    'View::Email' => {
            # Where to look in the stash for the email information.
            # 'email' is the default, so you don't have to specify it.
            stash_key => 'email',
            # Define the defaults for the mail
            default => {
                # Defines the default content type (mime type). Mandatory
                content_type => 'text/plain',
                # Defines the default charset for every MIME part with the 
                # content type text.
                # According to RFC2049 a MIME part without a charset should
                # be treated as US-ASCII by the mail client.
                # If the charset is not set it won't be set for all MIME parts
                # without an overridden one.
                # Default: none
                charset => 'utf-8'
            },
            # Setup how to send the email
            # all those options are passed directly to Email::Sender::Simple
            sender => {
                # if mailer doesn't start with Email::Sender::Simple::Transport::,
                # then this is prepended.
                mailer => 'SMTP',
                # mailer_args is passed directly into Email::Sender::Simple 
                mailer_args => {
                    host     => 'smtp.googlemail.com', # defaults to localhost
                    ssl      => 1, 
                    port     => 465,
		                timeout => 10,
		    sasl_username => '',
                    sasl_password => '',
            }
          }
        },
    'View::JSON' => {
          expose_stash => 'json_data',
        },
    #remove stale sessions from db
    'Plugin::Session' => {
        expires           => 28800,
        dbi_dbh           => 'IPAdminDB',
        dbi_table         => 'sessions',
        dbi_id_field      => 'id',
        dbi_data_field    => 'session_data',
        dbi_expires_field => 'expires',
    }
);

sub check_backref {
	    my $c       = shift;
	    my $backref = $c->flash->{'backref'};
	    return $backref;
}

sub set_backref : Private {
   my $c       = shift;
   my $backref = $c->req->param('backref');
   if ($backref) {
    $c->flash( backref => $backref );
    delete $c->request->parameters->{'backref'};
   }
}


########################################################################

########################################################################

after setup_finalize => sub {


    #default admin ACL for full CRUD and only root resources
    my @CRUD        = qw/create edit delete view list/;
    my @controllers = qw/department user building area subnet vlan typerequest/;

    foreach my $ctrl (@controllers) {
        foreach (@CRUD) {
            __PACKAGE__->allow_access_if( "$ctrl/$_",  sub {
               my $c = shift;
               return $c->user_in_realm( "normal" );             
             }
            );
            __PACKAGE__->deny_access_unless( "$ctrl/$_", [qw/admin/] );
        }
    }



    my @actions = qw{ userldap/list iprequest/list iprequest/activate managerrequest/list alias/activate
    managerrequest/delete managerrequest/activate alias/list userldap/listmanager};

    #additional ACL for admin
    foreach my $ctrl (@actions) {
      __PACKAGE__->allow_access_if( "$ctrl",  sub {
         my $c = shift;
         return $c->user_in_realm( "normal" ); 
      }
    );
    
      __PACKAGE__->deny_access_unless( "$ctrl", [qw/admin/] );
    }

    # Additional acl for admin privileges
    # my @admin_acl =
    #     qw{ building/view
    # };
    # foreach my $acl (@admin_acl) {
    #     __PACKAGE__->deny_access_unless( $acl, [qw/admin/] );
    # }

    #Acl for manager privileges
    my @manager_acl =
        qw{ 
    };
    foreach my $acl (@manager_acl) {
        __PACKAGE__->deny_access_unless( $acl, [qw/admin manager/] );
    }
};


# Start the application
__PACKAGE__->setup();


=head1 NAME

IPAdmin - Catalyst based application

=head1 SYNOPSIS

    script/ipadmin_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<IPAdmin::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Enrico Liguori

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
