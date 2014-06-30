# Copyright 2011 by the Manoc Team
#
# This library is free software. You can redistribute it and/or modify
# it under the same terms as Perl itself.
package IPAdmin::Manoc::Result::Device;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->table('devices');
__PACKAGE__->add_columns(
    id => {
        data_type   => 'varchar',
        is_nullable => 0,
        size        => 15,
    },
    rack => {
        data_type      => 'int',
        is_nullable    => 0,
        is_foreign_key => 1,
    },
    level => {
        data_type   => 'int',
        is_nullable => 0,
    },
    name => {
        data_type     => 'varchar',
        size          => 128,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    model => {
        data_type     => 'varchar',
        size          => 32,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    vendor => {
        data_type     => 'varchar',
        size          => 32,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    os => {
        data_type     => 'varchar',
        size          => 32,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    os_ver => {
        data_type     => 'varchar',
        size          => 32,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    vtp_domain => {
        data_type     => 'varchar',
        size          => 64,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    boottime => {
        data_type     => 'int',
        default_value => '0',
    },
    last_visited => {
        data_type     => 'int',
        default_value => '0',
    },
    offline => {
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    notes => {
        data_type   => 'text',
        is_nullable => 1,
    },
    telnet_pwd => {
        data_type     => 'varchar',
        size          => 255,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    enable_pwd => {
        data_type     => 'varchar',
        size          => 255,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    snmp_com => {
        data_type     => 'varchar',
        size          => 255,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    snmp_user => {
        data_type     => 'varchar',
        size          => 50,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    snmp_password => {
        data_type     => 'varchar',
        size          => 50,
        default_value => 'NULL',
        is_nullable   => 1,
    },
    snmp_ver => {
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    backup_enable => {
        accessor      => 'backup_enabled',
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    get_arp => {
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    get_mat => {
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    get_dot11 => {
        data_type     => 'int',
        size          => 1,
        default_value => '0',
    },
    mat_native_vlan => {
        data_type     => 'int',
        default_value => '1',
        is_nullable   => 1,
    },
    vlan_arpinfo => {
        data_type     => 'int',
        default_value => 'NULL',
        is_nullable   => 1,
    },
    mng_url_format => {
        data_type      => 'int',
        is_nullable    => 1,
        is_foreign_key => 1,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/id/] );

__PACKAGE__->belongs_to( rack => 'IPAdmin::Manoc::Result::Rack' );
__PACKAGE__->has_many( ifstatus     => 'IPAdmin::Manoc::Result::IfStatus' );
__PACKAGE__->has_many( uplinks      => 'IPAdmin::Manoc::Result::Uplink' );
__PACKAGE__->has_many( ifnotes      => 'IPAdmin::Manoc::Result::IfNotes' );
__PACKAGE__->has_many( ssids        => 'IPAdmin::Manoc::Result::SSIDList' );
__PACKAGE__->has_many( dot11clients => 'IPAdmin::Manoc::Result::Dot11Client' );
__PACKAGE__->has_many( dot11assocs  => 'IPAdmin::Manoc::Result::Dot11Assoc' );
__PACKAGE__->has_many( mat_assocs   => 'IPAdmin::Manoc::Result::Mat' );

__PACKAGE__->belongs_to( mat_native_vlan => 'IPAdmin::Manoc::Result::Vlan' );
__PACKAGE__->belongs_to( vlan_arpinfo    => 'IPAdmin::Manoc::Result::Vlan' );

__PACKAGE__->has_many(
    neighs => 'IPAdmin::Manoc::Result::CDPNeigh',
    { 'foreign.from_device' => 'self.id' },
    { delete_cascade        => 0 }
);

__PACKAGE__->might_have(
    config => 'IPAdmin::Manoc::Result::DeviceConfig',
    { 'foreign.device' => 'self.id' },
    {
        cascade_delete => 1,
        cascade_copy   => 1,
    }
);

__PACKAGE__->belongs_to(
    mng_url_format => 'IPAdmin::Manoc::Result::MngUrlFormat',
    'mng_url_format',
    { join_type => 'left' }
);

sub get_mng_url {
    my $self = shift;

    my $format = $self->mng_url_format;
    return unless $format;

    my $str    = $format->format;
    my $ipaddr = $self->id;
    $str =~ s/%h/$ipaddr/go;

    return $str;
}

1;
