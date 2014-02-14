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

__PACKAGE__->config(
    name         => 'IPAdmin',
    default_view => 'TT',
    use_request_uri_for_path => 1,

    enable_catalyst_header => 1, # Send X-Catalyst header

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    'Plugin::Authentication'                    => {
        default_realm => 'progressive',
        realms        => {
            progressive => {
                class  => 'Progressive',
                realms => [ 'normal', 'ldap' ],
            },
            normal => {
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
            ldap => {
             credential => {
               class => "Password",
               password_field => "password",
               password_type => "self_check",
             },
             store => {
               binddn              => "",
               bindpw              => "",
               class               => "LDAP",
               ldap_server         => "",
               ldap_server_options => { timeout => 30 },
               role_basedn         => "", #This should be the basedn where the LDAP Objects representing your roles are.
               role_field          => "cn",
               role_filter         => "(&(objectClass=posixGroup)(memberUid=%s))",
               role_scope          => "one",
               role_search_options => { deref => "always" },
               role_value          => "dn",
               role_search_as_user => 0,
               start_tls           => 1,
               start_tls_options   => { verify => "none" },
               entry_class         => "Net::LDAP::Entry",
               use_roles           => 1,
               user_basedn         => "",
               user_field          => "uid",
               user_filter         => "(&(objectClass=User)(cn=%s))",
               user_scope          => "one", # or "sub" for Active Directory
               user_search_options => { deref => "always" },
               user_results_filter => sub { return shift->pop_entry },
             },
            },
          },
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
